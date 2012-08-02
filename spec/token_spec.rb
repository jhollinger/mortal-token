require File.dirname(__FILE__) + '/spec_helper'

describe MortalToken do
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
