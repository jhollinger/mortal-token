class MortalToken
  # Holds a specific a configuration of parameters
  class Configuration
    RAND_SEEDS = [(0..9), ('a'..'z'), ('A'..'Z')].map(&:to_a).flatten # :nodoc;

    # The configuration's name
    attr_reader :name
    # The master secret token (Keep it secret! Keep it safe!). Changing this will invalidate all existing tokens.
    attr_accessor :secret
    # The number of encryption rounds. Defaults to 5. Changing this will invalidate existing tokens.
    attr_accessor :rounds
    # The units that life is measured in - :days, :hours or :minutes
    attr_reader :units
    # The number of units tokens will be valid across. Defaults to 2, which (for :days) prevents a
    # token generated at 23:59 from expiring at 00:00. Changing this will invalidate existing tokens.
    attr_accessor :valid_across
    # The maximum salt length, defaults to 50
    attr_accessor :max_salt_length
    # The minimum salt length, defaults to 10
    attr_accessor :min_salt_length

    # Instantiates a new Configuration object default values
    def initialize(name)
      @name = name
      @rounds = 5
      @units = :days
      @valid_across = 2
      @max_salt_length = 50
      @min_salt_length = 10
      # A temporary secret key. Use your own!!
      @secret = CONFIGS[:default] ? CONFIGS[:default].salt : self.salt
    end

    # Return a new token using this configuration
    def token(salt=nil, time=nil)
      Token.new(salt, time, self)
    end

    # Set the units that life is measured in - :days, :hours or :minutes
    def units=(unit)
      raise ArgumentError, "MortalToken.units must be one of #{UNITS.keys.join(', ')}" unless UNITS.keys.include? unit
      @units = unit
    end

    # Returns a random string of between min_salt_length and max_salt_length alphanumeric charachters
    def salt
      max_length = [self.min_salt_length, rand(self.max_salt_length + 1)].max
      pool_size = RAND_SEEDS.size
      (0..max_length).map { RAND_SEEDS[rand(pool_size)] }.join('')
    end
  end
end
