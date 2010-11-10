APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require "rubygems"
require "bundler/setup"
Bundler.require(:default)

Bitly.use_api_version_3

require APP_ROOT + '/lib/message'

begin
  C = YAML.load_file(APP_ROOT + '/auth.yml')
rescue Exception => e
  puts e
  exit
end

ActiveRecord::Base.establish_connection(YAML::load(File.open('database.yml')))
#deactivate in production 
ActiveRecord::Base.logger = Logger.new(File.open(APP_ROOT + '/database.log', 'a'))
 
