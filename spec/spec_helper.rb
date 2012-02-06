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
        t.integer :birthtime
        t.integer :wrong_time_name
        t.integer :wrong_date_name
        t.integer :ignore_time
        t.integer :ignore_date
        t.integer :not_time_count
        t.integer :not_date_count
      end

      create_table :exempts do |t|
        t.integer :birthdate
        t.integer :birthtime
      end
    end

    class User < ActiveRecord::Base
      self.skip_decimal_date_attributes = [ :ignore_date ]
      self.extra_decimal_date_attributes = [ :wrong_date_name ]
      self.skip_decimal_time_attributes = [ :ignore_time ]
      self.extra_decimal_time_attributes = [ :wrong_time_name ]
    end

    class Exempt < ActiveRecord::Base
      self.decimal_date_attributes = false
      self.decimal_time_attributes = false
    end

    FactoryGirl.find_definitions
  end
end
