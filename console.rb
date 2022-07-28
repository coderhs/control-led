require 'pry'
require 'bunny'

connection = Bunny.new(automatically_recover: false)
connection.start

@channel = connection.create_channel
@queue = @channel.queue('bluetooth_color_code')

COLOR_ARRAY = {
  red: "\x7e\x07\x05\x03\xff\x00\x00\x00\xef",
  blue: "\x7e\x07\x05\x03\x00\x2e\xff\x00\xef",
  green: "\x7e\x07\x05\x03\x00\xff\x09\x00\xef"
}
ON = "\x7e\x04\x04\xf0\x01\x01\xff\x00\xef"
OFF = "\x7e\x04\x04\x10\x01\x00\xff\x00\xef"

red = COLOR_ARRAY[:red]
blue = COLOR_ARRAY[:blue]
green = COLOR_ARRAY[:green]

def pub code
  @channel.default_exchange.publish(code, routing_key: @queue.name)
end

binding.pry
