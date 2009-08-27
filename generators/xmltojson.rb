require 'rubygems'
require 'xmlsimple'
require 'json'
require 'ftools'



data = XmlSimple.xml_in(File.dirname(__FILE__) + "/amqp0-8.xml")

File.open("amqp0-8.json","w") do |f|
	f.write(JSON.pretty_generate(data))
end