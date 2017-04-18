require './pmrmq.rb'

PMRMQ.subscribe(ARGV[0], ARGV[1]) do |message|
  puts message
  STDOUT.flush
end

STDIN.gets
