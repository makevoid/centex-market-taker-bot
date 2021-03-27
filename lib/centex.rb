# usage:
#
#   Order = Struct.new :side, :amount, :price, :coin keyword_init: true
#   order = Order.new(
#     amount: "3",
#     price:  "0.00005",
#     coin:   :CTH,
#   )
#   c = Centex.new
#   c.place_order order: order
#   # returns the current mid price from centex tickers API
#
require 'bigdecimal'
require_relative 'mid_price'

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

  def hmac_sig_generate(nonce:, path:, req_body:)
    hmac_key = Base64.strict_decode64 CENTEX_API_SECRET
    hmac_message = "#{path}#{nonce}#{req_body}"
    api_sig_hmac = OpenSSL::HMAC.digest "SHA256", hmac_key, hmac_message
    api_sig_hmac = Base64.strict_encode64 api_sig_hmac
    api_sig_hmac
  end

end

class Centex

  PATH = File.expand_path '../..', __FILE__

  include CentexAPIAuth
  include MidPrice

  API_HOST = "https://api.centex.io"
  TICKERS_URL = "#{API_HOST}/v1/public/tickers"
  ORDERBOOK_URL = "#{API_HOST}/v1/public/orderbook?symbol=%s"
  PLACE_ORDER_URL_PATH = "/v1/trading/order"
  PLACE_ORDER_URL = "#{API_HOST}#{PLACE_ORDER_URL_PATH}"
  # BALANCE_URL_PATH = "/v1/account/balance?symbol=%s"
  # BALANCE_URL = "#{API_HOST}#{PLACE_ORDER_URL_PATH}"

  CENTEX_API_KEY_ID = "2c593c1aa29042fea16d6e08de7ee853"

  ALT_PAIRS = {
    CNTX: "CNTX-BTC",
    SFD:  "SFD-BTC",
    BULL: "BULL-BTC",
    DNO:  "DNO-BTC",
    BTCI: "BTCI-USDT",
    CTH:  "CTH-ETH",
    REA:  "REA-BTC",
    ATC2: "ATC2-BTC",
    DTH:  "DTH-ETH",
  }

  NONCE_FILE_PATH = "#{PATH}/data/centex-api-nonce.txt"

  attr_reader :order

  def initialize(order:)
    @order = order
  end

  def orderbook_get(symbol:, depth: 1)
    url = ORDERBOOK_URL % symbol
    resp = Excon.get url
    body = resp.body
    JSON.parse body
  end

  def orderbook(symbol:)
    orderbook = orderbook_get
    orderbook.transform_keys &:to_sym
  end

  def bids
    orderbook.fetch :bids
  end

  def order_place_post(order:)
    nonce = nonce_next
    nonce = nonce.to_s
    ticker_id = ALT_PAIRS.fetch order.coin
    params = {
      ticker_id:  ticker_id,
      side:       order.side,
      price:      order.price,
      volume:     order.amount,
    }
    req_body = params.transform_keys(&:to_s).to_json
    path = PLACE_ORDER_URL_PATH
    hmac_sig = hmac_sig_generate nonce: nonce, req_body: req_body, path: path
    prefix = "Centex-API"
    headers = {
      "#{prefix}-key"       => CENTEX_API_KEY_ID,
      "#{prefix}-signature" => hmac_sig,
      "#{prefix}-nonce"     => nonce,
      "Content-Type"        => "application/json"
    }
    resp = Excon.post PLACE_ORDER_URL, headers: headers, body: req_body
    body = resp.body
    JSON.parse body
  end

  def place_order
    resp = order_place_post order: order
    puts "resp: #{resp.inspect}"
    resp
  end

  def self.place_order(order:)
    new(order: order).place_order
  end

  def nonce_next
    if File.exists? NONCE_FILE_PATH
      nonce = File.read NONCE_FILE_PATH
      nonce = nonce.to_i
      write_nonce nonce: nonce+1
      nonce
    else
      write_nonce
      0
    end
  end

  private

  def write_nonce(nonce: "0")
    File.open(NONCE_FILE_PATH, "w"){ |f| f.write nonce }
  end

  FindTicker = -> (pair) {
    -> (tick) {
      ticker_id = tick.fetch "ticker_id"
      ticker_id == pair
    }
  }

  def ticker(symbol:)
    tickers = tickers_get
    tickers = JSON.parse tickers
    pair = ALT_PAIRS.fetch symbol
    ticker = tickers.find &FindTicker.(pair)
    {
      bid: ticker.fetch("bid"),
      ask: ticker.fetch("ask"),
      mid: mid_price(ticker),
    }
  end

  def self.ticker(symbol:)
    new.ticker symbol: symbol
  end

  def tickers_get
    resp = Excon.get TICKERS_URL
    resp.body
  end

end

if __FILE__ == $0
  require 'bundler'
  Bundler.require :default
  require_relative '../env_secret'
  Order = Struct.new :side, :amount, :price, :coin, keyword_init: true
  order = Order.new(
    side:   "buy",
    price:  "0.000045",
    amount: "1",
    coin:   :CTH,
  )
  c = Centex.new order: order
  price = c.send :ticker, symbol: :CTH
  puts "price - bid: #{"%.6f" % price[:bid]}, ask: #{"%.6f" % price[:ask]}, mid: #{"%.6f" % price[:mid]} (ETH)"
  c.place_order
end
