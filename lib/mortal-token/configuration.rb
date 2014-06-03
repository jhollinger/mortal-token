class MortalToken
  # Holds a specific a configuration of parameters
  class Configuration
    RAND_SEEDS = [(0..9), ('a'..'z'), ('A'..'Z')].map(&:to_a).flatten # :nodoc;

    # The configuration's name
    attr_reader :name
    # The master secret token (Keep it secret! Keep it safe!). Changing this will invalidate all existing tokens.
    attr_accessor :secret
    # The digest to use (passed to OpenSSL::Digest.new). Defaults to 'sha256'.
    attr_accessor :digest
    # The units that life is measured in - :days, :hours or :minutes (defaults to :hours)
    attr_reader :units
    # The number of units tokens will be valid across. Defaults to 1. Changing this will invalidate existing tokens.
    attr_accessor :valid_for
    # The maximum salt length, defaults to 50
    attr_accessor :max_salt_length
    # The minimum salt length, defaults to 10
    attr_accessor :min_salt_length

    # Instantiates a new Configuration object default values
    def initialize(name)
      @name = name
      @digest = 'sha256'
      @units = :hours
      @valid_for = 1
      @max_salt_length = 50
      @min_salt_length = 10
      @secret = CONFIGS[:default].secret if CONFIGS[:default]
    end

    # Return a new token using this configuration
    def token(salt=nil, expires=nil)
      Token.new(salt, expires, self)
    end

    # Returns a token reconstitued from the timestamp and salt
    def check(salt, expires)
      Token.new(salt, expires, self)
    end

    # Set the units that life is measured in - :days, :hours or :minutes
    def units=(unit)
      raise ArgumentError, "MortalToken.units must be one of #{Token::UNITS.keys.join(', ')}" unless Token::UNITS.keys.include? unit
      @units = unit
    end

    # Returns a random string of between min_salt_length and max_salt_length alphanumeric charachters
    def salt
      max_length = [self.min_salt_length, rand(self.max_salt_length + 1)].max
      pool_size = RAND_SEEDS.size
      (0..max_length).map { RAND_SEEDS[rand(pool_size)] }.join('')
    end

    def _digest # :nodoc:
      @_digest ||= OpenSSL::Digest.new(self.digest)
    end
  end
end
