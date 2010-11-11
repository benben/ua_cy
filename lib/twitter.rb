require 'lib/env'

EventMachine::run {
  stream = Twitter::JSONStream.connect(
		#production:
    :path    => '/1/statuses/filter.json?track=utopiaattraktor,%23ua2011',
		#for testing:
		#:path    => '/1/statuses/filter.json?track=sport',
    :auth    => C['twitter_user'] + ':' + C['twitter_pass']
  )

	def object_parsed(obj)
	  m = {
	    :message_id => obj[:new_id_str],
	    :time => DateTime.parse(obj[:created_at]).strftime('%s'),
      :text => obj[:text],
      :user_id => obj[:user][:screen_name],
      :user_name => obj[:user][:name],
      :via => 'twitter'
    }
    if Message.create(m)
      puts m.inspect
      puts
		end
  end

	@parser = Yajl::Parser.new(:symbolize_keys => true)
	@parser.on_parse_complete = method(:object_parsed)

 	def connection_completed
  	# once a full JSON object has been parsed from the stream
  	# object_parsed will be called, and passed the constructed object
	end

  stream.each_item do |item|
    # Do someting with unparsed JSON item.
    @parser << item
  end

  stream.on_error do |message|
    # No need to worry here. It might be an issue with Twitter. 
    # Log message for future reference. JSONStream will try to reconnect after a timeout.
		puts "ERROR: #{message}"
  end

  stream.on_max_reconnects do |timeout, retries|
    # Something is wrong on your side. Send yourself an email.
  end
}

