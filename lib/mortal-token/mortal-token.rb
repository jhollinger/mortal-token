# A token hash that "self-destructs" after a certain time.
class MortalToken
  RAND_SEEDS = [(0..9), ('a'..'z'), ('A'..'Z')].map(&:to_a).flatten # :nodoc;
  UNITS = {days: {increment: 1, format: '%Y-%m-%d'}, hours: {increment: 3600, format: '%Y-%m-%d_%H'}, minutes: {increment: 60, format: '%Y-%m-%d_%H:%M'}} # :nodoc:

  class << self
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

  # The token's salt
  attr_reader :salt

  # To create a brand new token, do *not* pass any arguments. To validate a hash from
  # an existing token, pass the existing token's salt.
  def initialize(salt=nil, start_time=nil)
    @salt = salt || MortalToken.salt
    @start_time = start_time || (MortalToken.units == :days ? Date.today : Time.now.utc)
  end

  # Returns the hash value of the token
  def hash
    @hash ||= (0..MortalToken.rounds-1).inject("#{MortalToken.secret}_#{salt}_#{end_time.strftime(strfmt)}") do |val, i|
      Digest::SHA512.hexdigest(val)
    end
  end

  alias_method :to_s, :hash

  # Tests this token against another token or token hash
  def ==(other_token_or_hash)
    each_time do |time|
      guess = MortalToken.new(salt, time)
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
    @start_time + (MortalToken.valid_across - 1) * increment
  end

  # Returns the earliest possible date/time this token could have been valid.
  def earliest_time
    @start_time - (MortalToken.valid_across - 1) * increment
  end

  # Returns the incrementor for the configured unit
  def increment
    UNITS[MortalToken.units][:increment]
  end

  # Returns the string formater for the configured unit
  def strfmt
    UNITS[MortalToken.units][:format]
  end
end
