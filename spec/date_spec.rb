require 'spec_helper'

describe 'Date adapter' do
  describe 'column selection' do
    it 'should only apply to columns that look like dates' do
      u = Factory :user
      u.not_date_count = 19990101.0
      u.save!
      u.not_date_count.should == 19990101.0
    end

    it 'should ignore columns added to skip_decimal_date_attributes' do
      decimal = 19990101.0
      u = Factory :user
      u.ignore_date = decimal
      u.save!
      u.ignore_date.should == decimal
    end

    it 'should apply to columns added to extra_decimal_date_attributes' do
      date = Date.civil(1999, 1, 1)
      u = Factory :user
      u.wrong_date_name = date
      u.save!
      u.wrong_date_name.should == date
    end

    it 'should not do anything if decimal_date_attributes is false' do
      decimal = 19990101.0
      n = Factory :exempt
      n.birthdate = decimal
      n.save!
      n.birthdate.should == decimal
    end
  end

  describe 'with valid dates' do
    {
      19990101.0 => Date.civil(1999, 1, 1),
      20120202.0 => Date.civil(2012, 2, 2),
    }.each do |decimal, date|
      it "should store #{date} as #{decimal}" do
        u = Factory :user
        u.birthdate = date
        u.save!
        u.birthdate_before_type_cast.should == decimal
      end

      it "should retrieve #{date} as #{date}" do
        u = Factory :user
        u.birthdate = date
        u.save!
        u.birthdate.should == date
      end

      it "should retrieve #{decimal} as #{date}" do
        u = Factory :user
        User.update(u.id, :birthdate => decimal)
        u.reload
        u.birthdate.should == date
      end
    end
  end

  describe 'with invalid dates' do
    [
      1230101.0,    # year too low
      100000101.0,  # year too high
      20121301.0,   # month too high
      20121232.0,   # day too high
      20120230.0,   # day too high
      20110229.0,   # no leap day in 2011
      19000229.0,   # no leap day in 1900
    ].each do |decimal|
      it "should retrieve the out-of-range decimal #{decimal} as nil" do
        u = Factory :user
        User.update(u.id, :birthdate => decimal)
        u.reload
        u.birthdate.should == nil
      end
    end
  end
end
