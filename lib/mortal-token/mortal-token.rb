# A token hash that "self-destructs" after a certain time.
class MortalToken
  # Seeds for generating random strings
  RAND_SEEDS = [(0..9), ('a'..'z'), ('A'..'Z')].map(&:to_a).flatten

  class << self
    # The master secret token (Keep it secret! Keep it safe!). Changing this will invalidate all existing tokens.
    attr_accessor :secret
    # The number of encryption rounds. Defaults to 5. Changing this will invalidate existing tokens.
    attr_accessor :rounds
    # The number of days tokens will be valid across. Defaults to 2, which prevents a
    # token generated at 23:59 from expiring at 00:00. Changing this will invalidate existing tokens.
    attr_accessor :valid_across
    # The maximum salt length, defaults to 50
    attr_accessor :max_salt_length
    # The minimum salt length, defaults to 10
    attr_accessor :min_salt_length

    # Returns a random string of between min_salt_length and max_salt_length alphanumeric charachters
    def salt
      max_length = rand(self.max_salt_length + 1)
      max_length = self.min_salt_length if max_length < self.min_salt_length
      pool_size = RAND_SEEDS.size
      (0..max_length).map { RAND_SEEDS[rand(pool_size)] }.join('')
    end
  end

  # The token's salt
  attr_reader :salt

  # To create a brand new token, do *not* pass any arguments.
  #
  # If you want to validate a hash from an existing token, pass
  # the existing token's salt. You should usually leave "start_date" alone.
  def initialize(salt=nil, start_date=nil)
    @salt = salt || MortalToken.salt
    @start_date = start_date || Date.today
  end

  # Returns the hash value of the token
  def hash
    val = [MortalToken.secret, salt, @start_date, end_date].join('_')
    MortalToken.rounds.times { val = Digest::SHA512.hexdigest(val) }
    val
  end

  # Alias to MortalToken::Token.hash
  def to_s
    hash
  end

  # Tests this token against another token or token hash
  def ==(other_token_or_hash)
    other_hash = other_token_or_hash.to_s
    (earliest_date).upto(@start_date) do |date|
      guess = MortalToken.new(salt, date)
      return true if guess.to_s == other_hash
    end
    return false
  end

  alias_method :===, :==

  private

  # Returns the end date of this token
  def end_date
    @start_date + (MortalToken.valid_across - 1)
  end

  # Returns the earliest possible date this token could have been valid.
  # Only useful when checking for validity.
  def earliest_date
    @start_date - (MortalToken.valid_across - 1)
  end
end
