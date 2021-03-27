require 'json'
require 'bigdecimal'
require 'bundler'

APP_ENV = ENV["APP_ENV"] || ENV["RACK_ENV"] || "development"

Bundler.require :default, APP_ENV

path = File.expand_path '../', __FILE__
PATH = path

TWILIO_SID = ""
TWILIO_TOKEN = ""
TWILIO_NUMBER = ""

require_relative 'config/conf' # NOTE: edit this conf to set your buy/
require_relative 'env_secret'  # NOTE: see readme, you need to configure the secrets to be able to start the app
require_relative 'lib/monkeypatches'
require_relative 'lib/centex'
require_relative 'lib/sms'

raise "No secret `CENTEX_API_SECRET`" unless defined? CENTEX_API_SECRET
