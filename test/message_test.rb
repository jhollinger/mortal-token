require 'mortal-token'
require 'minitest/autorun'

class MessageTest < Minitest::Test
  def setup
    MortalToken.secret = 'qwer'
  end

  def test_message_survives
    token_str = MortalToken.create(60, 'so long and thanks for all the fish').to_s
    token, digest = MortalToken.recover token_str
    assert token == digest
    assert_equal 'so long and thanks for all the fish', token.message
  end

  def test_tampered_message_invalidates
    original_token = MortalToken.create(60, 'so long and thanks for all the fish')
    plain_token_str = Base64.urlsafe_decode64 original_token.to_s
    tampered_plain_token_str = plain_token_str.sub('fish', 'fishes')
    tampered_token_str = Base64.urlsafe_encode64 tampered_plain_token_str
    tampered_token, digest = MortalToken.recover tampered_token_str
    assert_equal original_token.expires, tampered_token.expires
    assert_equal original_token.salt, tampered_token.salt
    refute_equal original_token.message, tampered_token.message
    refute tampered_token == digest
  end
end
