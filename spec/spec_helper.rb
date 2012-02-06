$: << "#{File.dirname(__FILE__)}/lib"
require 'activerecord-decimal-datetime-adapter'
require 'factory_girl'

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

    ActiveRecord::Schema.define(:version => 1) do
      create_table :users do |t|
        t.string :login
        t.integer :birthdate
        t.integer :login_time
        t.integer :login_count
      end
    end

    class User < ActiveRecord::Base ; end

    FactoryGirl.find_definitions
  end
end
