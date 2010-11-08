APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'active_record'
require 'logger'

require APP_ROOT + '/lib/message'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => APP_ROOT + '/db.sqlite')
#deactivate in production 
ActiveRecord::Base.logger = Logger.new(File.open(APP_ROOT + '/database.log', 'a')) 
