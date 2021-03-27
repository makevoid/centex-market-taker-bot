require_relative 'env'

class MarketTakerBot

  Order = Struct.new :side, :amount, :price, :coin, keyword_init: true

  FIVE_MINUTES = 60 * 5 # seconds

  Sms = SMS.new

  def check_for_new_orders
    amount  = 1
    price   = "0.000044"
    coin    = CONF.fetch :coin
    last_order = Order.new(
      side:   :sell,
      amount: amount,
      price:  price,
      coin:   coin,
    )
    last_order
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

  def create_matching_order(last_order:)
    side = last_order.side == :sell ? "buy" : "sell"
    Order.new(
      side:   side,
      amount: CONF.fetch(:amount),
      price:  last_order.price,
      coin:   CONF.fetch(:coin),
    )
  end

  def main_tick
    last_order = check_for_new_orders
    order = create_matching_order last_order: last_order
    # send_sms_alert order: order
    place_order order: order
  end

  def main_loop
    loop do
      main_tick
      sleep FIVE_MINUTES
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
