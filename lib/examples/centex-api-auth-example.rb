# prerequisite: `gem install excon`
#
# usage:
#
#  ruby centex-api-auth-example.rb
#
#  or require this file and:
#
#  Centex.balance symbol: "ETH"
#
#
# with bundler:
# require 'bundler'
# Bundler.require :default
#
# # Gemfile:
# # source "https://rubygems.org"
# # gem "excon"

require 'json'
require 'base64'
require 'excon'

# configure your API credentials here (use an env variable or a configuration file for the API secret)
CENTEX_API_KEY_ID = ""
CENTEX_API_SECRET = ""

# use an environment variable or a conf. file for the secret - e.g. CENTEX_API_SECRET = ENV["CENTEX_API_SECRET"]

module CentexAPIAuth

  def centex_headers(hmac_sig:, nonce:)
    prefix = "Centex-API"
    {
      "#{prefix}-key"       => CENTEX_API_KEY_ID,
      "#{prefix}-signature" => hmac_sig,
      "#{prefix}-nonce"     => nonce,
      "Content-Type"        => "application/json"
    }
  end

  def hmac_sig_generate(nonce:, path:)
    hmac_key = Base64.strict_decode64 CENTEX_API_SECRET
    hmac_message = "#{path}#{nonce}"
    api_sig_hmac = OpenSSL::HMAC.digest "SHA256", hmac_key, hmac_message
    api_sig_hmac = Base64.strict_encode64 api_sig_hmac
    api_sig_hmac
  end

end

class Centex

  API_HOST = "https://api.centex.io"
  ACCOUNT_BALANCE_PATH = "/v1/account/balance?symbol=%s"
  ACCOUNT_BALANCE_URL  = "#{API_HOST}#{ACCOUNT_BALANCE_PATH}"

  include CentexAPIAuth

  def balance(symbol:)
    path = ACCOUNT_BALANCE_PATH % symbol
    nonce = Time.new.to_i
    hmac_sig = hmac_sig_generate nonce: nonce, path: path
    headers = centex_headers hmac_sig: hmac_sig, nonce: nonce
    url = ACCOUNT_BALANCE_URL % symbol
    resp = Excon.get url, headers: headers
    body = resp.body
    JSON.parse body
  end

  def self.balance(symbol:)
    new.balance symbol: symbol
  end

end

if $0 == __FILE__
  balance = Centex.balance symbol: "BTC"
  puts balance
end
