require 'mortal-token'
require 'minitest/autorun'

class TokenTest < Minitest::Test
  def setup
    MortalToken.secret = 'asdf'
  end

  def test_ttl
    token = MortalToken.create 60
    assert_equal 60, token.ttl
  end

  def test_valid_before_expiry
    token = MortalToken.create 60
    assert MortalToken.valid? token.to_s
  end

  def test_invalid_on_expiry
    token = MortalToken.create 0
    refute MortalToken.valid? token.to_s
  end

  def test_invalid_after_expiry
    token = MortalToken.create -10
    refute MortalToken.valid? token.to_s
  end

  def test_invalid_with_wrong_digest
    token_a = MortalToken.create 60
    token_b = MortalToken.create 60
    token, _ = MortalToken.recover token_a.to_s
    _, digest = MortalToken.recover token_b.to_s
    refute token == digest
  end

  def test_invalid_if_secret_changes
    token_str = MortalToken.create(60).to_s
    MortalToken.secret = 'different'
    refute MortalToken.valid? token_str
  end

  def test_recover_fails_if_token_str_is_invalid
    token, digest = MortalToken.recover 'nonense'
    refute token == digest
  end
end
