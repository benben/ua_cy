require 'lib/env'

class Ua < Sinatra::Application

	include Koala  

	set :root, APP_ROOT
	enable :sessions

	configure do
	  set :app_id, C["app_id"]
    set :app_code, C["app_code"]
    set :site_url, (C["site_url"] + 'callback')
	end

	get '/' do
		if session['access_token']
		@graph = Koala::Facebook::GraphAPI.new(session["access_token"])
		@profile = @graph.get_object("me")
			# do some stuff with facebook here
			# for example:
			# @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
			# publish to your wall (if you have the permissions)
			# @graph.put_wall_post("I'm posting from my new cool app!")
			# or publish to someone else (if you have the permissions too ;) )
			# @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")			
		end
		@messages = Message.find(:all, :order => "time DESC", :limit => 20)
		erb :index
	end

  get '/update' do
		begin
			last = Message.find(params[:last_id])
    	@messages = Message.where(["time >= ? and id != ?", last.time, last.id]).order("time DESC")
    	erb :_messages, :layout => false, :locals => {:messages => @messages}
		rescue
			''
		end
  end

	get '/login' do
		# generate a new oauth object with your app data and your callback url
		session['oauth'] = Facebook::OAuth.new(options.app_id, options.app_code, options.site_url)
		# redirect to facebook to get your code
		redirect session['oauth'].url_for_oauth_code(:permissions => "publish_stream")
	end

	get '/logout' do
		session['oauth'] = nil
		session['access_token'] = nil
		redirect '/'
	end
	
	get '/callback' do
		#get the access token from facebook
		session['access_token'] = session['oauth'].get_access_token(params[:code])
		redirect '/'
	end

	get '/send' do
		unless params[:message].empty?
			if session['access_token']
				@graph = Koala::Facebook::GraphAPI.new(session["access_token"])
				@profile = @graph.get_object("me")
				id = @graph.put_wall_post(params[:message] + " - sent from http://www.utopiaattraktor.org/")['id']
					  m = {
	    			:message_id => id,
	    			:time => Time.now.strftime('%s'),
      			:text => params[:message],
      			:user_id => @profile['id'],
      			:user_name => @profile['name'],
      			:via => 'utopiaattraktor'
    				}
				if Message.create(m)
					'Deine Nachricht wurde an den Attraktor gesendet!'
				else
					'Fehler!'	
				end
			end
		else
			'Bitte fülle das Textfeld aus!'
		end
	end

	get '/display' do
		if session['access_token']
			erb :display
		end
	end

	get '/wall' do
		@messages = Message.find(:all, :order => "time DESC", :limit => 20)
		erb :wall
	end
	
	def urlconv (m)
    s = m.text.gsub( Regexp.new('((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'), '<a href="\1">\1</a>' )    
    if m.via == "twitter"
      s = s.gsub( Regexp.new('(@([_a-zA-Z0-9\-]+))'), '<a href="http://twitter.com/\2" title="\2 on Twitter">\1</a>' )
      s = s.gsub( Regexp.new('(#([_a-zA-Z0-9\-]+))'), '<a href="http://search.twitter.com/search?q=%23\2" title="Search for \1 on Twitter">\1</a>' )
    end
    s
	end
	
	def make_name (m)
	  if m.via == "twitter"
	    '<a href="http://twitter.com/' + m.user_id + '">' + m.user_name + '</a>'
	  else
	    '<a href="http://www.facebook.com/profile.php?id=' + m.user_id + '">' + m.user_name + '</a>'
	  end
	end
	
	def make_time (m)
	  if m.via == "twitter"
	    "<a href=\"http://twitter.com/#{m.user_id}/status/#{m.message_id}\">" + Time.at(m.time).strftime("%d.%m.%Y %H:%M:%S") + "</a>"
	  else
	    "<a href=\"http://www.facebook.com/permalink.php?story_fbid=#{m.message_id.split('_')[1]}&id=#{m.user_id}\">" + Time.at(m.time).strftime("%d.%m.%Y %H:%M:%S") + "</a>"
	  end
	end
end

