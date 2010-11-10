require 'lib/env'

@graph = Koala::Facebook::GraphAPI.new
@user = @graph.get_object("utopiaattraktor")
@bitly = Bitly.new(C['bitly_user'], C['bitly_api_key'])

EventMachine::run do
  timer = EventMachine::PeriodicTimer.new(5) do
    
    feed = @graph.get_connections(@user["id"], "feed")
    
    if last = Message.where(:via => 'facebook').order("time DESC").first
      last_id = last.message_id
      last_time = last.time
    else
      last_id = 0
      last_time = 0
    end
    
    feed.each do |post|
      #puts post['id']
      #puts post['from']['name'] + "(" + post['from']['id'] + ")"
      #puts post['message']
      #puts post['link'] unless post['link'].nil?
      #puts post['created_time']
      #puts post['source'] if post['type'] == 'video' unless post['type'].nil?
      #puts "################################################################################"
      
      #only process the post if its created time younger then the last post processed and if it has another id
      if DateTime.parse(post['created_time']).strftime('%s').to_i >= last_time and post['id'] != last_id
        #only process if the post has a link field
        unless post['link'].nil?
          #delete the link from the message if its occur there
          post['message'].gsub!(post['link'], "") if post['message'].include? post['link']
          #strip the http:// and the trailing /
          l = post['link'].gsub("http://","")
          l = l.chop if l[-1] == 47
          #delete this if this occurs in the message
          if post['message'].include? l
            post['message'].gsub!(l, "")
          end
          
          link = post['link']
        else
          unless post['type'].nil?
            if post['type'] == 'video'
              link = post['source']
            end
          end
        end
        
        if link.nil?
          link = ""
        else
          link = " " + @bitly.shorten(link).short_url
        end
        
        m = {
          :message_id => post['id'],
          :time => DateTime.parse(post['created_time']).strftime('%s'),
          :text => post['message'] + link,
          :user_id => post['from']['id'],
          :user_name => post['from']['name'],
          :via => 'facebook'
        }
        
        if Message.create(m)
          puts m.inspect
          puts
        end
      end
    end
  end
  trap("SIGINT") { exit! }
end
 