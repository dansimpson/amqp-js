require 'rubygems'
require 'json'
require 'active_support'
require 'erb'
require 'ftools'

s = JSON.parse(File.read(File.dirname(__FILE__) + "/amqp-0.8.json"))

OUTPUT_ROOT = File.dirname(__FILE__) + "/as3/org/ds/amqp"

TYPE_MAP = {
	'bit' 		=> {
		'type'	=> 'Boolean',
		'meth'	=> 'Bit',
		'def'	=> 'false'
	},
	'short' 	=> {
		'type'	=> 'uint',
		'meth'	=> 'ShortInt',
		'def'	=> '0'
	},
	'long' 		=> {
		'type'	=> 'uint',
		'meth'	=> 'LongInt',
		'def'	=> '0'
	},
	'longlong' 	=> {
		'type'	=> 'Long',
		'meth'	=> 'LongLong',
		'def'	=> 'new Long(0,0)'
	},
	'shortstr' 	=> {
		'type'	=> 'String',
		'meth'	=> 'ShortString',
		'def'	=> '""'
	},
	'longstr' 	=> {
		'type'	=> 'String',
		'meth'	=> 'LongString',
		'def'	=> '""'
	},
	'table' 	=> {
		'type'	=> 'FieldTable',
		'meth'	=> 'Table',
		'def'	=> 'new FieldTable()'
	},
	'octet' 	=> {
		'type'	=> 'uint',
		'meth'	=> 'Octet',
		'def'	=> '0'
	},
	'timestamp'	=> {
		'type'	=> 'Date',
		'meth'	=> 'Timestamp',
		'def'	=> 'new Date()'
	}
}


def get_type mqtype
	TYPE_MAP[mqtype]['type']
end

def get_method mqtype
	TYPE_MAP[mqtype]['meth']
end

def get_default mqtype
	TYPE_MAP[mqtype]['def']
end

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
  File.makedirs(OUTPUT_ROOT + "/headers")
  File.open(OUTPUT_ROOT + "/headers/#{c['name'].titleize.gsub(/\s/,'')}.as", 'w') do |f|
    f.write(ERB.new(File.read('templates/class.erb'), nil, '<>-%').result(binding))
  end

  
  c['methods'].each do |m|
    File.open(OUTPUT_ROOT + "/#{c['name']}/#{c['name'].titleize.gsub(/\s/,'')}#{m['name'].titleize.gsub(/\s/,'')}.as", 'w') do |f|
      f.write(ERB.new(File.read('templates/method.erb'), nil, '<>-%').result(binding))
    end

  end
end

