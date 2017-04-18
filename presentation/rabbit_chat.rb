require "bunny"

current_thread = "#{Process.pid}-#{Thread.current.object_id}"

t = Thread.new do
  conn = Bunny.new
  conn.start
  ch = conn.create_channel
  q = ch.queue("testchat")

  loop do
    x, y, m = q.pop
    if m
      message_thread, message = Marshal.load(m)
      if message_thread != current_thread
        puts "#{message_thread}: #{message}"
        STDOUT.flush
      end
    else
      sleep 0.1
    end
  end
end

conn = Bunny.new
conn.start
ch = conn.create_channel
q = ch.queue("testchat")
while((input = gets) != "\n")
  q.publish(Marshal.dump([current_thread, input]))
end

t.exit


