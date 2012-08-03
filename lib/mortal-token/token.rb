class MortalToken
  class Token
    # The token's salt
    attr_reader :salt
    attr_accessor :config

    # To create a brand new token, do *not* pass any arguments. To validate a hash from
    # an existing token, pass the existing token's salt.
    def initialize(salt=nil, start_time=nil, config=nil)
      @config = config || MortalToken.config
      @salt = salt || config.salt
      @start_time = start_time || (config.units == :days ? Date.today : Time.now.utc)
    end

    # Returns the hash value of the token
    def hash
      @hash ||= (0..config.rounds-1).inject("#{config.secret}_#{salt}_#{end_time.strftime(strfmt)}") do |val, i|
        Digest::SHA512.hexdigest(val)
      end
    end

    alias_method :to_s, :hash

    # Tests this token against another token or token hash
    def ==(other_token_or_hash)
      each_time do |time|
        guess = config.token(salt, time)
        return true if guess.to_s == other_token_or_hash.to_s
      end
      return false
    end

    alias_method :===, :==

    private

    # Iterates over each possible time unit and passes it to the block
    def each_time(&block)
      time = earliest_time
      while time <= end_time
        block.call(time)
        time += increment
      end
    end

    # Returns the end date/time of this token
    def end_time
      @start_time + (config.valid_across - 1) * increment
    end

    # Returns the earliest possible date/time this token could have been valid.
    def earliest_time
      @start_time - (config.valid_across - 1) * increment
    end

    # Returns the incrementor for the configured unit
    def increment
      UNITS[config.units][:increment]
    end

    # Returns the string formater for the configured unit
    def strfmt
      UNITS[config.units][:format]
    end
  end
end
