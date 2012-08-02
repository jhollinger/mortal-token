class MortalToken
  # Set defaults
  self.rounds = 5
  self.valid_across = 2
  self.max_salt_length = 50
  self.min_salt_length = 10
  # Set a temporary secret key. You should set your own consistent key.
  # Otherwise, existing tokens will be invalidated each time the library is loaded.
  self.secret = self.salt
end
