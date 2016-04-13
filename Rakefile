require 'securerandom'
require 'nsq'

# Write messages to the queue.
task :producer do |task|
  begin
    # Connect to NSQ
    producer = Nsq::Producer.new(
        nsqd: ENV['QUEUE_ENDPOINT'],
        topic: ENV['TOPIC_NAME']
    )

    # Send messages in an infinite loop
    loop do
      message = SecureRandom.uuid

      # Write a message to the queue
      puts "Sending: #{message}"
      producer.write(message)

      sleep(0.1)
    end

  rescue SystemExit, Interrupt
    puts 'Shutting down'
  rescue StandardError => e
    puts "ERROR: #{e.inspect}"
  ensure
    # Close the connection
    producer.terminate
    puts 'Connection closed'
  end
end

# Read messages from the queue.
task :consumer do |task|
  begin
    # Connect to NSQ
    consumer = Nsq::Consumer.new(
      nsqd: ENV['QUEUE_ENDPOINT'],
      topic: ENV['TOPIC_NAME'],
      channel: ENV['CHANNEL_NAME'],
    )

    # Listen for messages in an infinite loop
    loop do
      # Pop a message off the queue
      msg = consumer.pop
      puts "Receiving: #{msg.body}"
      msg.finish

      sleep(0.1)
    end

  rescue SystemExit, Interrupt
    puts 'Shutting down'
  rescue StandardError => e
    puts "ERROR: #{e.inspect}"
  ensure
    # Close the connection
    consumer.terminate
    puts 'Connection closed'
  end
end
