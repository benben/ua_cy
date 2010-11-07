APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'active_record'
require 'logger'

#fixme: build a rake task for it!
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => APP_ROOT + '/db.sqlite')
#deactivate in production 
ActiveRecord::Base.logger = Logger.new(File.open(APP_ROOT + '/database.log', 'a')) 
#fixme: build a rake task for it!
ActiveRecord::Schema.define do
    create_table :messages do |t|
			t.integer :message_id
			t.date :date
			t.string :text
			t.string :user_id
			t.string :user_name
			t.string :via
    end
end

