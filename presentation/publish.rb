require './pmrmq.rb'

input = nil
while(input != "\n") do
  input = STDIN.gets
  PMRMQ.publish(ARGV[0], input)
end
