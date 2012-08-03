require File.dirname(__FILE__) + '/spec_helper'

describe MortalToken do
  context 'days' do
    it "should be valid and equal right after being created" do
      token = MortalToken.new
      copy = MortalToken.new(token.salt)
      copy.should === token
      copy.should === token.to_s
    end

    it "should be valid if created yesterday" do
      token = MortalToken.new(nil, Date.today - 1)
      copy = MortalToken.new(token.salt)
      copy.should === token
      copy.should === token.to_s
    end

    it "should be valid if created a month ago" do
      old_token = MortalToken.new(nil, Date.today - 30)
      MortalToken.new(old_token.salt).should_not === old_token
      MortalToken.new(old_token.salt).should_not === old_token.to_s
    end

    it "should not be equal to another token" do
      MortalToken.new.should_not === MortalToken.new
    end

    it "should not be valid if the secret changes" do
      token = MortalToken.new
      hash = token.hash

      MortalToken.secret = 'changed'

      copy = MortalToken.new(token.salt)
      copy.should_not == hash
    end
  end

  context 'hours' do
    before(:each) { MortalToken.units = :hours }

    it "should be valid and equal right after being created" do
      token = MortalToken.new
      copy = MortalToken.new(token.salt)
      copy.should === token
      copy.should === token.to_s
    end

    it "should be valid if created one hour ago" do
      token = MortalToken.new(nil, Time.now.utc - 3600)
      copy = MortalToken.new(token.salt)
      copy.should === token
      copy.should === token.to_s
    end

    it "should not be valid if created two hours ago" do
      token = MortalToken.new(nil, Time.now.utc - 7200)
      copy = MortalToken.new(token.salt)
      copy.should_not === token
    end
  end

  context 'minutes' do
    before(:each) { MortalToken.units = :minutes }

    it "should be valid and equal right after being created" do
      token = MortalToken.new
      copy = MortalToken.new(token.salt)
      copy.should === token
      copy.should === token.to_s
    end

    it "should be valid if created one minute ago" do
      token = MortalToken.new(nil, Time.now.utc - 60)
      copy = MortalToken.new(token.salt)
      copy.should === token
      copy.should === token.to_s
    end

    it "should not be valid if created two minutes ago" do
      token = MortalToken.new(nil, Time.now.utc - 120)
      copy = MortalToken.new(token.salt)
      copy.should_not === token
    end
  end
end
