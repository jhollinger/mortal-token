class MortalToken
  class Token
    UNITS = {days: {increment: 86400}, hours: {increment: 3600}, minutes: {increment: 60}} # :nodoc:

    # The salt value
    attr_reader :salt
    # The expiry time as a Unix timestamp
    attr_reader :expires
    attr_reader :config # :nodoc:

    # To create a brand new token, do *not* pass any arguments. To validate a digest from
    # an existing token, pass the existing token's exiry timestamp.
    def initialize(salt=nil, expires=nil, config=nil)
      @config = config || MortalToken.config
      @salt = salt || self.config.salt
      @expires = expires ? expires.to_i : calculate_expiry
    end

    # Returns the hash digest of the token
    def digest
      raise "MortalToken: you must set a secret!" if config.secret.nil?
      @digest ||= OpenSSL::HMAC.digest(config._digest, config.secret, "#{expires.to_s}:#{salt}")
    end

    # A URL-safe Base64-encoded digest
    def urlsafe_digest
      Base64.urlsafe_encode64(self.digest)
    end

    # Returns true if the token expires soon. Default check: within 5 min.
    def expires_soon?(min=5)
      Time.now.utc.to_i + (min * 60) >= expires
    end

    # Returns salt, expires, digest. Convenient for one-line assignment of all three.
    def get
      return salt, expires, digest
    end

    alias_method :to_s, :digest

    # Tests this token against another token or token hash. Accepts a block. If the check passes,
    # this token will be passed to the block.
    def against(other_token_or_digest)
      if self == other_token_or_digest
        yield self if block_given?
        true
      else
        false
      end
    end

    # Tests this token against another token or token hash. Even if it matches, returns false if
    # the expire time is past.
    def ==(other_token_or_digest)
      other = other_token_or_digest.to_s
      (self.digest == other || self.urlsafe_digest == other) && self.expires > Time.now.utc.to_i
    end

    alias_method :===, :==

    private

    # Returns the end date/time of this token
    def calculate_expiry
      expire_time = Time.now.utc.to_i + ((config.valid_for) * UNITS[config.units][:increment])
      expire_time.to_i
    end
  end
end
