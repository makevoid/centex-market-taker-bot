require_relative 'env'

class MarketTakerBot

  Order = Struct.new :side, :amount, :price, :coin, keyword_init: true

  ONE_MINUTE = 60 # seconds

  Sms = SMS.new

  def last_offer_get
    symbol = CONF.fetch :coin
    last_offer = Centex.offers(symbol: symbol).last
    price, _ = last_offer
    {
      price: price
    }
  end

  def send_sms_alert(order:)
    type = order.side == :buy ? "taker" : "maker"
    side_verb = order.side == :buy ? "bought" : "sold"
    message = "Market #{type} order placed - #{side_verb} #{order.amount} cTH @ #{order.price}"
    Sms.deliver message: message, to: SMS_ALERT_NUMBER
  end

  # place taker trade (for maker order you may want to implement this differently)
  #
  #   order_match: order to match
  #
  def place_order(order:)
    puts "placing order: #{order.side} #{order.amount} @ #{order.price} (#{Time.now.strftime "%H:%M"})"
    Centex.place_order order: order
  end

  def create_matching_order(last_offer_price:)
    side    = CONF.fetch :side
    amount  = CONF.fetch :amount
    coin    = CONF.fetch :coin
    Order.new(
      side:   side.to_s,
      amount: amount,
      price:  last_offer_price,
      coin:   coin,
    )
  end

  def main_tick
    last_offer = last_offer_get
    max_buy_price = CONF.fetch :price
    last_offer_price = last_offer.fetch :price
    last_offer_price = last_offer_price.to_f
    if last_offer_price <= max_buy_price
      order = create_matching_order last_offer_price: last_offer_price
      # send_sms_alert order: order
      place_order order: order
      puts
    else
      print "." # print a dot when skipping
    end
  end

  def main_loop
    loop do
      main_tick
      sleep CONF.fetch(:every) * ONE_MINUTE
    end
  end

  def auto_stop
    Thread.new do
      sleep
      exit
    end
  end

  def strategy
    buy if price < set_price
  end

  def self.main_loop
    new.main_loop
  end

end

if $0 == __FILE__
  bot = MarketTakerBot.new
  bot.main_loop
end
