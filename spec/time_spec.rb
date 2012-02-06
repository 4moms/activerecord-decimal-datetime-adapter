require 'spec_helper'

today = DateTime.now

describe 'Time adapter' do
  describe 'column selection' do
    it 'should only apply to time-related columns' do
      decimal = 12345678.0
      u = Factory :user
      u.not_time_count = decimal
      u.save!
      u.reload
      u.not_time_count.should == decimal
    end

    it 'should ignore columns in skip_decimal_time_attributes' do
      decimal = 12345678.0
      u = Factory :user
      u.ignore_time = decimal
      u.save!
      u.reload
      u.ignore_time.should == decimal
    end

    it 'should apply to columns in extra_decimal_time_attributes' do
      time = DateTime.new(today.year, today.month, today.day, 12, 34, 56.78)
      u = Factory :user
      u.wrong_time_name = time
      u.save!
      u.reload
      u.wrong_time_name.should == time
    end

    it 'should not do anything if decimal_time_attributes is false' do
      decimal = 12345678.0
      e = Factory :exempt
      e.birthtime = decimal
      e.save!
      e.reload
      e.birthtime.should == decimal
    end
  end

  describe 'with valid times' do
    {
      12345678.0 => DateTime.new(today.year, today.month, today.day, 12, 34, 56.78),
         10203.0 => DateTime.new(today.year, today.month, today.day,  0,  1,  2.03),
    }.each do |decimal, time|
      it "should retrieve #{decimal} as #{time}" do
        u = Factory :user
        User.update(u.id, :birthtime => decimal)
        u.reload
        u.birthtime.should == time
      end

      it "should store #{time} as #{decimal}" do
        u = Factory :user
        u.birthtime = time
        u.save!
        u.reload
        u.birthtime_before_type_cast.should == decimal
      end

      it "should retrieve #{time} as #{time}" do
        u = Factory :user
        u.birthtime = time
        u.save!
        u.reload
        u.birthtime.should == time
      end
    end
  end

  describe 'with invalid times' do
    [
      25000000.0,
      99000000.0,
        610000.0,
        990000.0,
          6100.0,
          9900.0,
    ].each do |decimal, time|
      it "should retrieve the out-of-range decimal #{decimal} as nil" do
        u = Factory :user
        User.update(u.id, :birthtime => decimal)
        u.reload
        u.birthtime.should == nil
      end
    end
  end
end
