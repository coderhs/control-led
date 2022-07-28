#!/usr/bin/env ruby
require 'bunny'
require 'ble'
require 'pry'
#-------------------------------------------------------------------
module BLE
  module Service
    add '0000fff0-0000-1000-8000-00805f9b34fb',
        name: 'Led Strip',
        nick: :led_strip

  end

  class Characteristic
    add '0000fff3-0000-1000-8000-00805f9b34fb',
        name: 'led state',
        nick: :led_state,
        in: ->(s) { s }
  end
end

COLOR_ARRAY = {
  'red' => "\x7e\x07\x05\x03\xff\x00\x00\x00\xef",
  'blue' => "\x7e\x07\x05\x03\x00\x2e\xff\x00\xef",
  'green' => "\x7e\x07\x05\x03\x00\xff\x09\x00\xef",
  'random_color' => ["\x7e\x07\x05\x03\x00\xff\x09\x00\xef",
                     "\x7e\x07\x05\x03\xb3\x00\xff\x00\xef",
                     "\x7e\x07\x05\x03\x00\x2e\xff\x00\xef",
                     "\x7e\x07\x05\x03\xff\x00\x00\x00\xef",
                     "\x7e\x07\x05\x03\xcc\xff\x00\x00\xef",
                     "\x7e\x07\x05\x03\xff\x00\x00\x00\xef",
                     "\x7e\x07\x05\x03\x00\x2e\xff\x00\xef",
                     "\x7e\x07\x05\x03\x00\xff\x09\x00\xef"]
}


$a = BLE::Adapter.new('hci0')
puts "Info: #{$a.iface} #{$a.address} #{$a.name}"

$d = $a['30:09:20:88:91:42'] # nrf PCA10056 683537939
if $d.connect
    puts "Connected to #{$d.name}"
else
    raise "Connecting to #{$d.name} failed"
end


connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel
queue = channel.queue('bluetooth_color_code')

begin
  puts ' [*] Waiting for messages. To exit press CTRL+C'
  # block: true is only used to keep the main thread
  # alive. Please avoid using it in real world applications.
  queue.subscribe(block: true) do |delivery_info, properties, body|
    puts "#{Time.now.strftime('%D %I:%M %p')} #{body} #{delivery_info} #{properties}"
    $d.write(:led_strip, :led_state, body)
    begin
      $d.write(:led_strip, :led_state, body)
    rescue
      $d.refresh
      $d.connect
      sleep(5)
      $d.write(:led_strip, :led_state, body)
    end
  end
rescue Interrupt => _
  connection.close
  $d.disconnect

  exit(0)
end
