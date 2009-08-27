require 'rubygems'
require 'crack'
require 'active_support'
require 'erb'
require 'json'
require 'ftools'

OUTPUT_ROOT = File.dirname(__FILE__) + "/as3/org/ds/amqp"
s = JSON.parse(File.read(File.dirname(__FILE__) + "/amqp0-8.json"))

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
		'type'	=> 'uint',
		'meth'	=> 'LongLong',
		'def'	=> '0'
	},
	'shortstr' 	=> {
		'type'	=> 'String',
		'meth'	=> 'ShortString',
		'def'	=> '""'
	},
	'longstr' 	=> {
		'type'	=> 'ByteArray',
		'meth'	=> 'LongString',
		'def'	=> 'new ByteArray()'
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

s['class'].each do |c|
	File.makedirs(OUTPUT_ROOT + "/#{c['name']}")
	File.makedirs(OUTPUT_ROOT + "/headers")
	File.open(OUTPUT_ROOT + "/headers/#{c['name'].titleize.gsub(/\s/,'')}.as", 'w') do |f|
		f.write(ERB.new(File.read('templates/class.erb'), nil, '<>-%').result(binding))
	end


	c['method'].each do |m|
		if m['field']
			unless m['field'].kind_of?(Array)
				m['field'] = [m['field']]
			end
		end

		if m['response']
			unless m['response'].kind_of?(Array)
				m['response'] = [m['response']]
			end
		end

		File.open(OUTPUT_ROOT + "/#{c['name']}/#{c['name'].titleize.gsub(/\s/,'')}#{m['name'].titleize.gsub(/\s/,'')}.as", 'w') do |f|
			f.write(ERB.new(File.read('templates/method.erb'), nil, '<>-%').result(binding))
		end
	end
end

