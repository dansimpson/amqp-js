require 'rubygems'
require 'mq'
require 'json'

EM.run{
  amq = MQ.new
  
  EM.add_periodic_timer(20) {

    json = {
      :amount => rand(10000),
      :msg => "queue"
    }.to_json
    
    puts "Sending Message #{json}";

    amq.queue("tester").publish(json)
    amq.topic('maki').publish(json, :key => "block")
    amq.topic('maki').publish(json, :key => "noblock")
  }
}


