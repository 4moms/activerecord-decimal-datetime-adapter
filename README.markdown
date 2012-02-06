# ActiveRecord Decimal Datetime Adapter

We have to work with a legacy database that stores its date and time columns as
\[decimal](9,0).

By way of examples:

The date January 24, 1981 is stored as the number 19810124.0.
The time 12:34PM and 56.78 seconds is stored as the number 12345678.0.

This gem allows you to store and retrieve values from such columns as Date objects.

# Usage

Add it to your Gemfile:

    gem 'activerecord-decimal-datetime-adapter'

By default, it will "just work"™ for all subclasses of ActiveRecord::Base.  It
will treat all numeric columns with names ending in 'date' or 'time'
(case-insensitive) as dates or times, respectively.

If you want to exclude columns, you can add them to one of the class variables:

    class User < ActiveRecord::Base
      self.skip_decimal_date_attributes = [ :ignore_date ]
      self.skip_decimal_time_attributes = [ :ignore_time ]
    end

If you want to include columns that don't fit the naming conventions, you can
add them to one of the class variables:

    class User < ActiveRecord::Base
      self.extra_decimal_date_attributes = [ :misnamed_thing ]
      self.extra_decimal_time_attributes = [ :misnamed_thing ]
    end

If you want to disable the conversions by default, you can set the class
variables:

    class UnconvertedThing < ActiveRecord::Base
      self.decimal_date_attributes = false
      self.decimal_time_attributes = false
    end
