require 'rubygems'
require 'mq'
require 'json'

EM.run{
  amq = MQ.new
  
  EM.add_periodic_timer(2) {

    json = {
      :amount => rand(10000),
      :msg => "queue"
    }.to_json
    
    puts "Sending Message #{json}";

    #amq.queue("amq.gen-yZO6kfPY0xWjkttNSnTt9Q==").publish(json)
    amq.topic('testex').publish(json, :key => "kt")
    #amq.topic('maki').publish(json, :key => "noblock")
  }
}


