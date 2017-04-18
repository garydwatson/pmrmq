require "net/http"
require "uri"
require "redis"
require 'json'
require 'benchmark'

url = "http://www.google.com/"
url = "http://www.cnn.com/"

def get_web_page(url)
  uri = URI.parse(url) 
  Net::HTTP.get_response(uri).body
end

def pull_urls_from_html_and_convert_any_relative_to_absolute(html, url)
  # get the urls from that page
  urls = html.scan(/href\s*=\s*(?:'[^']+'|"[^"]+")/)

  # get rid of the href and double and single quotes
  urls.map! {|i| i.match(/href\s*=\s*('([^']+)'|"([^"]+)")/)[2] || i.match(/href\s*=\s*('([^']+)'|"([^"]+)")/)[3] }

  # seperate out the absolute urls
  absolute_urls = urls.select {|i| i.match(/^http.*/) }

  # seperate out the relative urls
  relative_urls = urls.reject {|i| i.match(/^http.*/) }

  # strip leading slash if there is one from the relative urls and then tranform it to absolute url and add the result to the absolute url list
  absolute_urls.push(relative_urls.map {|i| i = i[1..-1] if i[0] == "/"; url + i })

  absolute_urls.flatten
end

puts(Benchmark.measure do

  urls = pull_urls_from_html_and_convert_any_relative_to_absolute(get_web_page(url), url)

  redis = Redis.new

  urls.each_with_index do |url, index|
    redis.lpush("testqueue", [index, url].to_json)
  end

  processes = []

  (0...8).each do
    processes << fork do
      redis = Redis.new

      while json = redis.rpop('testqueue')
        work = JSON.parse(json)

        File.open(work[0].to_s, 'w') do |f|
          f << get_web_page(work[1])
        end
      end
    end
  end

  processes.each do |process|
    puts process
    Process.wait(process)
  end

end)
