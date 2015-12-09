module MortalToken
  class << self
    # The master secret token (Keep it secret! Keep it safe!). Changing this will invalidate all existing tokens.
    attr_accessor :secret
    # The digest to use. Defaults to 'sha512'.
    attr_reader :digest
    # Salt length in bytes. Defaults to 8.
    attr_accessor :salt_length
  end

  # Set a new digest type
  def self.digest=(name)
    @digest = OpenSSL::Digest.new name
  end

  self.digest = 'sha512'
  self.salt_length = 8
end
