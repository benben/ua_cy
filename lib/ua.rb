require 'lib/env'

class Ua < Sinatra::Application

	include Koala  

	set :root, APP_ROOT
	enable :sessions

	configure do
		begin
			c = YAML.load_file('auth.yml')
			set :app_id, c["app_id"]
			set :app_code, c["app_code"]
			set :site_url, (c["site_url"] + 'callback')
		rescue Exception => e
			puts e
		end
	end

	get '/' do
		if session['access_token']
			# do some stuff with facebook here
			# for example:
			# @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
			# publish to your wall (if you have the permissions)
			# @graph.put_wall_post("I'm posting from my new cool app!")
			# or publish to someone else (if you have the permissions too ;) )
			# @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")			
		end
		@messages = Message.find(:all, :order => "id DESC", :limit => 20)
		erb :index
	end

  get '/update' do
    @messages = Message.where(["id > ?", params[:last_id]]).order("id DESC")
    erb :_messages, :layout => false, :locals => {:messages => @messages}
  end

	get '/login' do
		# generate a new oauth object with your app data and your callback url
		session['oauth'] = Facebook::OAuth.new(options.app_id, options.app_code, options.site_url)
		# redirect to facebook to get your code
		redirect session['oauth'].url_for_oauth_code()
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
	
	def urlconv (status)
    s = status.gsub( Regexp.new('((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'), '<a href="\1">\1</a>' )    
    s = s.gsub( Regexp.new('(@([_a-zA-Z0-9\-]+))'), '<a href="http://twitter.com/\2" title="\2 on Twitter">\1</a>' )
    s = s.gsub( Regexp.new('(#([_a-zA-Z0-9\-]+))'), '<a href="http://search.twitter.com/search?q=%23\2" title="Search for \1 on Twitter">\1</a>' )
	end
end

