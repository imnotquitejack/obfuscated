# VERY Helpful:
# http://iain.nl/testing-activerecord-in-isolation

require 'active_record'
require 'mysql2'
require 'rspec/rails/extensions/active_record/base'

ActiveRecord::Base.establish_connection(
  :adapter => "mysql", :database => "arbitrary", 
  :username => 'root', :password => 'root', 
  :socket => "/Applications/MAMP/tmp/mysql/mysql.sock"
)

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Migration.drop_table :posts rescue nil
    ActiveRecord::Migration.drop_table :comments rescue nil
    ActiveRecord::Migration.create_table :posts do |t|
      t.string :name
      t.timestamps
    end
    ActiveRecord::Migration.create_table :comments do |t|
      t.integer :post_id
      t.string :content
      t.timestamps
    end
  end

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.after(:suite) do
    ActiveRecord::Migration.drop_table :posts
    ActiveRecord::Migration.drop_table :comments
  end
end