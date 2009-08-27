require 'rubygems'
require 'crack'
require 'json'
require 'ftools'

data = Crack::XML.parse(File.read(File.dirname(__FILE__) + "/amqp0-8.xml"))

puts data
puts JSON.pretty_generate(data)

File.open("amqp0-8.json","w") do |f|
	f.write(JSON.pretty_generate(data))
end