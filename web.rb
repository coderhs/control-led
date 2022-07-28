

require "sinatra"
require 'bunny'

connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel
queue = channel.queue('bluetooth_color_code')


COLOR_ARRAY = {
  red: "\x7e\x07\x05\x03\xff\x00\x00\x00\xef",
  blue: "\x7e\x07\x05\x03\x00\x2e\xff\x00\xef",
  green: "\x7e\x07\x05\x03\x00\xff\x09\x00\xef"
}
ON = "\x7e\x04\x04\xf0\x01\x01\xff\x00\xef"
OFF = "\x7e\x04\x04\x10\x01\x00\xff\x00\xef"

str = "<center> <br><br><a href='/red' style='font-size:30px'>Red<a> <br><br><br> <a href='/blue' style='font-size:30px'>blue<a> <br><br> <br> <a href='/green' style='font-size:30px'>green<a><br><br> <br><br><a href='/alert' style='font-size:30px'>alert<a></center>"

get '/' do
  str
end

get '/red' do
  channel.default_exchange.publish(COLOR_ARRAY[:red], routing_key: queue.name)
  str
end

get '/blue' do
  channel.default_exchange.publish(COLOR_ARRAY[:blue], routing_key: queue.name)
  str
end

get '/green' do
  channel.default_exchange.publish(COLOR_ARRAY[:green], routing_key: queue.name)
  str
end

def authorized?
  @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ["admin","admin123"]
end

def protected!
  unless authorized?
    response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
    throw(:halt, [401, "Oops... we need your login name & password\n"])
  end
end


admin_str = "<center> <br><br><a href='/off' style='font-size:30px'>off<a> <br><br><br> <br><br><a href='/on' style='font-size:30px'>on<a></center>"


get '/admin' do
  protected!
  admin_str
end

get '/on' do
  protected!
  channel.default_exchange.publish(ON, routing_key: queue.name)
  admin_str
end

get '/off' do
  protected!
  channel.default_exchange.publish(OFF, routing_key: queue.name)
  admin_str
end

get '/alert' do
  (0..25).each do |i|
     if i.even?
      channel.default_exchange.publish(COLOR_ARRAY[:red], routing_key: queue.name)
     else
      channel.default_exchange.publish(COLOR_ARRAY[:blue], routing_key: queue.name)
     end
     sleep 0.1
   end
  str
end

get '/about' do
  str
end
