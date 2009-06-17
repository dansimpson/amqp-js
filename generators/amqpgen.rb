require 'rubygems'
require 'json'
require 'active_support'
require 'erb'
require 'ftools'

s = JSON.parse(File.read(File.dirname(__FILE__) + "/amqp-0.8.json"))

OUTPUT_ROOT = File.dirname(__FILE__) + "/as3/org/ds/amqp"

AS3_TYPES = {
  'bit' => 'Boolean',
  'short' => 'int',
  'long' => 'uint',
  'longlong' => 'uint',
  'shortstr' => 'String',
  'longstr' => 'String',
  'table' => 'Dictionary',
  'octet' => 'int',
  'timestamp' => 'Date'
}


def create_class c, s
  ERB.new(File.read('templates/class.erb'), nil, '<>-%').result(binding);
end

def create_method m, c, s
  ERB.new(File.read('templates/method.erb'), nil, '<>-%').result(binding);
end

def create_amqp s
  
end

File.makedirs(OUTPUT_ROOT)

File.open(OUTPUT_ROOT + "/AMQP.as", 'w') do |f|
  f.write(ERB.new(File.read('templates/amqp.erb'), nil, '>-').result(binding))
end


OUTPUT_ROOT << "/protocol"

s['classes'].each do |c|
  File.makedirs(OUTPUT_ROOT + "/#{c['name']}")
  File.open(OUTPUT_ROOT + "/#{c['name'].titleize.gsub(/\s/,'')}.as", 'w') do |f|
    f.write(ERB.new(File.read('templates/class.erb'), nil, '<>-%').result(binding))
  end

  
  c['methods'].each do |m|
    File.open(OUTPUT_ROOT + "/#{c['name']}/#{m['name'].titleize.gsub(/\s/,'')}.as", 'w') do |f|
      f.write(ERB.new(File.read('templates/method.erb'), nil, '<>-%').result(binding))
    end

  end
end

