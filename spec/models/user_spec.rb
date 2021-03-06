require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
        :name => "Example User",
        :email => "user@example.com",
        :password => "foobar",
        :password_confirmation => "foobar"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create! (@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new (@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@info.com user@foo.bar.org first.last@foo.org]

    addresses.each do |address|
      valid_email_address  = User.new(@attr.merge(:email => address))
      valid_email_address.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@info,com user_foo_bar.org first.last@foo]

    addresses.each do |address|
      valid_email_address  = User.new(@attr.merge(:email => address))
      valid_email_address.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)

    user_with_duplicate_email.should_not be_valid
  end

  it "should reject identical email addresses up to case" do
    upcased_email = @attr[:email].upcase

    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)

    user_with_duplicate_email.should_not be_valid
  end

  describe "password validations"do
    it "should require a password" do
      empty_password_user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      empty_password_user.should_not be_valid
    end

    it "should require matching password" do
      User.new(@attr.merge(:password_confirmation => "invalid password")).should_not be_valid
    end

    it "should reject short passwords" do
      short_password_user = User.new(@attr.merge(:password => "bo", :password_confirmation => "bo"))
      short_password_user.should_not be_valid
    end

    it "should reject long passwords" do
      long_password_user =  User.new(@attr.merge(:password => "a" * 41, :password_confirmation => "a" * 41))
      long_password_user.should_not be_valid
    end
  end

  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password?" do
      it "should return true if has password" do
         @user.has_password?(@attr[:password]).should be_true
      end

      it "should return false if has password" do
         @user.has_password?("invalid").should be_false
      end
    end

    describe "Authenticate" do
      it "should return nil if user email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:mail], "wrongPassword")
        wrong_password_user.should be_nil
      end

      it "should return nil if user with supplied email doesn't exist" do
        wrong_password_user = User.authenticate("boo.com", @attr[:password])
        wrong_password_user.should be_nil
      end

      it "should return correct user when matching email/password are supplied"do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

end
