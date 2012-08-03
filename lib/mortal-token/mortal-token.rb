# A token hash that "self-destructs" after a certain time.
class MortalToken
  CONFIGS = {} # :nodoc:
  UNITS = {days: {increment: 1, format: '%Y-%m-%d'}, hours: {increment: 3600, format: '%Y-%m-%d_%H'}, minutes: {increment: 60, format: '%Y-%m-%d_%H:%M'}} # :nodoc:

  class << self
    # Returns a new Token. Also alised to #token.
    def new(salt=nil, time=nil)
      config.token(salt, time)
    end

    # Returns a new or existing MortalToken::Configuration. If you pass a block, it will pass it the config object.
    # If it's a new config, it will inherit the default settings.
    def config(name=:default)
      config = (CONFIGS[name] ||= Configuration.new(name))
      yield config if block_given?
      config
    end

    alias_method :use, :config

    # Alias all other methods to the default Configuration
    def method_missing(method, *args, &block)
      config.send(method, *args, &block)
    end
  end
end
