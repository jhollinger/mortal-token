# MortalToken, because some tokens shouldn't live forever

MortalToken is a convenience wrapper for HMAC-based authentication. Tokens self-destruct after a specified time period; no need to store and look them up for verification. They may optionally contain a message, which is visible but tamper-proof.

## Simple token with validity check

    require 'mortal-token'
    MortalToken.secret = 'asdf092$78roasdjfjfaklmsdadASDFopijf98%2ejA#Df@sdf'

    token = MortalToken.create(60 * 60) # 1 hr
    give_to_client token.to_s
    token_str = get_from_client
    if MortalToken.valid? token_str
      # it's valid
    else
      # it's invalid or expired
    end

## Token with tamper-proof message

    require 'mortal-token'
    MortalToken.secret = 'asdf092$78roasdjfjfaklmsdadASDFopijf98%2ejA#Df@sdf'

    token = MortalToken.create(60 * 60, 'some message')
    give_to_client token.to_s
    token_str = get_from_client
    token, digest = MortalToken.recover(token_str)
    if token == digest
      # It's valid. But remember - the message could have been read by anyone with access to the token.
      do_stuff_with token.message
    else
      # it's invalid or expired
    end

## Tweak token parameters

You may tweak certain parameters of the library in order to make it more secure, less, faster, etc. These are the defaults:

    MortalToken.digest = 'sha512'  # The digest algorithm used by HMAC
    MortalToken.salt_length = 8    # Number of bits in tokens' salts

## Testing

    rake test
