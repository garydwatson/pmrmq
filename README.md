# pmrmq
Poor Man's Redis Message Queue

Redis has basic functionality for setting up message queues, and has ephemeral
pubsub functionality.  It does not implement message routing by default alla
direct routing in rabbitmq.  This library aims to solve that.  The case I had
in mind when I wrote this was to use this library to broadcast events that
occur in one app, and then allow any number of other applications to subscribe
to that event.  The reason why this is different from plain redis pub/sub is
because once an app has subscribed, messages will be delivered to that apps
inbox whether it's listening or not.  If one of the apps goes offline, the
messages will simply queue up until it comes back online and can consume the
messages.  The result is more reliable than plain redis pub/sub, but allows
passive subscription the way the plain pub/sub does.  The inboxes are
persistent, to get rid of one once a subscription has been made you have to
explicitly delete it.

This code is currently alpha quality, it's really a proof of concept at this
point to demonstrate how easy this is to setup.  Certain bits would need to be
changed to make it useful in the real world, like changing the Marshal
serialization to use JSON serialization instead, and for the subscribe mechanic
not forcing the user to keep the process open indefinitely.

# Example usage

to subscribe...
```
require './pmrmq.rb'
PMRMQ.subscribe('channel_name', 'inbox_name') do |message|
  # do whatever work here you want upon receipt of a message.
end

#ensure that the process doesn't end before you've processed whatever you want
to process.  This part of the interface could use some work, mabye adding
parameters that specify how many messages it will process currently the code is
setup as a demo of feacibility, needs help to be useful in production
```

to publish....

```
require './pmrmq.rb'
PMRMQ.publish('channel_name', 'put whatever payload you want here')
```
