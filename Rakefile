require 'lib/env.rb'

task :dbcreate do
  ActiveRecord::Schema.define do
      create_table :messages do |t|
        t.integer :id
        t.string :message_id
        t.integer :time
        t.string :text
        t.string :user_id
        t.string :user_name
        t.string :via
      end
  end
end
