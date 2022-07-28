#!/usr/bin/env ruby
require 'bunny'
require 'json'

connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel
queue = channel.queue('bluetooth_color_code')

color_array = ["\x7e\x07\x05\x03\x33\x42\x57\x00\xef",
               "\x7e\x07\x05\x03\xff\x00\x15\x00\xef",
               "\x7e\x07\x05\x03\x00\xff\x09\x00\xef",
               "\x7e\x07\x05\x03\xb3\x00\xff\x00\xef",
               "\x7e\x07\x05\x03\x00\x2e\xff\x00\xef",
               "\x7e\x07\x05\x03\xff\x00\x00\x00\xef",
               "\x7e\x07\x05\x03\xcc\xff\x00\x00\xef",
               "\x7e\x07\x05\x03\xff\x00\x00\x00\xef"]

ON = "\x7e\x04\x04\xf0\x01\x01\xff\x00\xef"
OFF = "\x7e\x04\x04\x10\x01\x00\x00\x00\xef"

# channel.default_exchange.publish(ON, routing_key: queue.name)
Time.now.strftime('%I').to_i.times do
  #color_array.each do |color|
    channel.default_exchange.publish(color_array.rotate!.first, routing_key: queue.name)
    #sleep 1
  #end
  sleep 2
end
# channel.default_exchange.publish(OFF, routing_key: queue.name)

connection.close
