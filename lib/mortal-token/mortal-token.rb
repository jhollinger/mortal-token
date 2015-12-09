module MortalToken
  # Create a new token that lasts for N seconds. Message is optional, but must be a string when present.
  def self.create(seconds, message = nil)
    expires = Time.now.utc.to_i + seconds
    salt = SecureRandom.hex MortalToken.salt_length
    Token.new expires, salt, message
  end

  # Recover a token and digest created with MortalToken#to_s. Returns [token, digest].
  # You must then check their validity with "token == digest"
  def self.recover(token_str)
    h = JSON.parse Base64.urlsafe_decode64 token_str.to_s
    token = Token.new h['expires'], h['salt'], h['message']
    return token, h['digest']
  rescue ArgumentError, JSON::ParserError
    nil
  end

  # Check if a token created with MoralToken#to_s is valid.
  def self.valid?(token_str)
    token, digest = recover token_str
    token == digest
  end
end
