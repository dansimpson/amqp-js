require 'rubygems'
require 'crack'
require 'json'
require 'ftools'

data = Crack::XML.parse(File.read(File.dirname(__FILE__) + "/amqp0-9-1.xml"))


File.open("amqp-0.9.1.json","w") do |f|
	f.write(JSON.pretty_generate(data))
end