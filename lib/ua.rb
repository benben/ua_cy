APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'sinatra'
require 'koala'
require 'yaml'

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
  
  helpers do

  end

	get '/' do
		if session['access_token']
		  'You are logged in! <a href="/logout">Logout</a>'
			# do some stuff with facebook here
			# for example:
			# @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
			# publish to your wall (if you have the permissions)
			# @graph.put_wall_post("I'm posting from my new cool app!")
			# or publish to someone else (if you have the permissions too ;) )
			# @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")			
		else
			'<a href="/login">Login</a>'
		end
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
end

