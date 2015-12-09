module MortalToken
  # Create a token and check if it's still valid:
  #
  #   token = MortalToken.create(300) # 5 min
  #   give_to_client token.to_s
  #   token_str = get_from_client
  #   MoralToken.valid? token_str
  #
  # Create a message token. The client *will* be able to read the message, but they *won't* be able to tamper with it.
  # If your message must aslo be read-proof, you'll have to encrypt it and decrypt it yourself.
  #
  #   token = MortalToken.create(300, "message")
  #   give_to_client token.to_s
  #   token_str = get_from_client
  #   token, digest = MortalToken.recover token_str
  #   if token == digest
  #     message = token.message
  #     # Do stuff with message
  #   else
  #     # The token was invalid or expired
  #   end
  #
  class Token
    # The expiry time as a Unix timestamp
    attr_reader :expires
    # String content of token (optional)
    attr_reader :message
    # The salt value
    attr_reader :salt

    # Initialize an existing token 
    def initialize(expires, salt, message = nil)
      @expires = expires.to_i
      @salt = salt
      @message = message ? message.to_s : nil
    end

    # Returns a URL-safe encoding of the token and its digest. Hand it out to users and check it with MoralToken.valid?
    def to_s
      h = to_h
      h[:digest] = digest
      Base64.urlsafe_encode64 h.to_json
    end

    # Returns the hash digest of the token
    def digest
      raise "MortalToken: you must set a secret!" if MortalToken.secret.nil?
      @digest ||= OpenSSL::HMAC.hexdigest(MortalToken.digest, MortalToken.secret, to_h.to_json)
    end

    # Number of seconds remaining
    def ttl
      expires - Time.now.utc.to_i
    end

    # Tests this token against another token or token hash. Even if it matches, returns false if
    # the expire time is past.
    def ==(other_token_or_digest)
      other = other_token_or_digest.respond_to?(:digest) ? other_token_or_digest.digest : other_token_or_digest
      self.digest == other && self.ttl > 0
    end

    alias_method :===, :==

    private

    def to_h
      {salt: salt, expires: expires, message: message}
    end
  end
end
