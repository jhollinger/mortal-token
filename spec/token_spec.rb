require File.dirname(__FILE__) + '/spec_helper'

describe MortalToken do
  before :each do
    MortalToken.secret = 'asdf'
    MortalToken.valid_for = 1
    MortalToken.units = :days
  end

  context 'fancy syntax' do
    it "should work" do
      token = MortalToken.new
      MortalToken.check(token.salt, token.expires).against(token.digest).should eq true
    end

    it "should work with user_id salt" do
      user_id = 42
      token = MortalToken.new(user_id)
      MortalToken.check(user_id, token.expires).against(token.digest).should eq true
    end
  end

  it "should know if it expires soon" do
    token = MortalToken.new(nil, Time.now.utc + 120)
    token.expires_soon?(3).should eq true
  end

  it "should know if it doesn't expires soon" do
    token = MortalToken.new
    token.expires_soon?.should eq false
  end

  context 'days' do
    it "should be valid and equal right after being created" do
      token = MortalToken.new
      copy = MortalToken.new(token.salt, token.expires)
      copy.should === token
      copy.should === token.to_s
    end

    it "should not be valid and equal right after being created, but with the wrong salt" do
      token = MortalToken.new
      copy = MortalToken.new(token.expires, 'ZZZ')
      copy.should_not === token
      copy.should_not === token.to_s
    end

    it "should be valid if created 12 hours ago" do
      token = MortalToken.new(nil, Time.now.utc + (60 * 60 * 12))
      copy = MortalToken.new(token.salt, token.expires)
      copy.should === token
      copy.should === token.to_s
    end

    it "should not be valid if created 2 days ago" do
      old_token = MortalToken.new(nil, Time.now.utc - (60 * 60 * 24))
      MortalToken.new(old_token.salt, old_token.expires).should_not === old_token
      MortalToken.new(old_token.salt, old_token.expires).should_not === old_token.to_s
    end

    it "should not be equal to another token" do
      MortalToken.new.should_not === MortalToken.new
    end

    it "should not be valid if the secret changes" do
      token = MortalToken.new
      hash = token.hash

      MortalToken.secret = 'changed'

      copy = MortalToken.new(token.salt, token.expires)
      copy.should_not == hash
    end
  end

  context 'hours' do
    before :all do
      MortalToken.config(:testing_hours) do |config|
        config.valid_for = 1
        config.units = :hours
      end
    end

    it "should be valid and equal right after being created" do
      MortalToken.use(:testing_hours) do |mt|
        token = mt.token
        copy = mt.token(token.salt, token.expires)
        copy.should === token
        copy.should === token.to_s
      end
    end

    it "should be valid if created one hour ago" do
      MortalToken.use(:testing_hours) do |mt|
        token = mt.token(Time.now.utc + 3600)
        copy = mt.token(token.salt, token.expires)
        copy.should === token
        copy.should === token.to_s
      end
    end

    it "should not be valid if created two hours ago" do
      MortalToken.use(:testing_hours) do |mt|
        token = mt.token(nil, Time.now.utc - 7200)
        copy = mt.token(token.salt, token.expires)
        copy.should_not === token
      end
    end
  end

  context 'minutes' do
    before(:each) { MortalToken.units = :minutes }

    it "should be valid and equal right after being created" do
      token = MortalToken.new
      copy = MortalToken.new(token.salt, token.expires)
      copy.should === token
      copy.should === token.to_s
    end

    it "should be valid if created one minute ago" do
      token = MortalToken.new(nil, Time.now.utc + 60)
      copy = MortalToken.new(token.salt, token.expires)
      copy.should === token
      copy.should === token.to_s
    end

    it "should not be valid if created two minutes ago" do
      token = MortalToken.new(nil, Time.now.utc - 60)
      copy = MortalToken.new(token.salt, token.expires)
      copy.should_not === token
    end
  end
end
