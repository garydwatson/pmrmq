require "redis"

current_thread = "#{Process.pid}-#{Thread.current.object_id}"

t = Thread.new do
  r = Redis.new

  r.subscribe(:testchat) do |on|
    on.message do |c, m|
      message_thread, message = Marshal.load(m)
      if message_thread != current_thread
        puts "#{message_thread}: #{message}"
        STDOUT.flush
      end
    end
  end
end

r = Redis.new
while((input = gets) != "\n")
  r.publish(:testchat, Marshal.dump([current_thread, input]))
end

t.exit


