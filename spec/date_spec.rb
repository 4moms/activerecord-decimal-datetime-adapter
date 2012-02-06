require 'spec_helper'

describe 'Date adapter' do
  describe 'column selection' do
    it 'should only apply to columns that look like dates' do
      u = Factory :user
      u.login_count = 19990101.0
      u.save!
      u.login_count.should == 19990101.0
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
    {
      1230101.0 => Date.civil(123, 1, 1),
      100000101.0 => Date.civil(10000, 1, 1),
    }.each do |decimal, date|
      it "should store the out-of-range date #{date} as nil" do
        u = Factory :user
        u.birthdate = date
        u.save!
        u.reload
        u.birthdate.should == nil
      end

      it "should retrieve the out-of-range decimal #{decimal} as nil" do
        u = Factory :user
        User.update(u.id, :birthdate => decimal)
        u.reload
        u.birthdate.should == nil
      end
    end
  end
end
