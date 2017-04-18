require 'redis'

class PMRMQ
  def self.subscribe(channel, inbox, &block)
    reactor = Reactor.new
    reactor.subscribe(channel, inbox, block)
  end

  def self.publish(channel, message)
    reactor = Reactor.new
    reactor.publish(channel, message)
  end

  private

  class Reactor
    def self.new
      @reactor ||= super
    end

    def initialize
      Thread.exclusive { @callbacks ||= [] }
      @redis ||= Redis.new

      t = Thread.new do
        redis = Redis.new

        begin
          loop do
            Thread.exclusive do
              @callbacks.each do |inbox, fn|
                x, payload = redis.brpop("inbox_#{inbox}", 0)
                fn.call(Marshal.load(payload))
              end
            end
          end
        ensure
          redis.close
        end
      end
    end

    def subscribe(channel, inbox, fn)
      Thread.exclusive {@callbacks << [inbox, fn]}

      @redis.sadd("subscriptions_#{channel}", inbox)
    end

    def publish(channel, message)
      inboxes = @redis.smembers("subscriptions_#{channel}")

      inboxes.each do |inbox|
        @redis.lpush("inbox_#{inbox}", Marshal.dump(message))
      end
    end
  end
  private_constant :Reactor
end
