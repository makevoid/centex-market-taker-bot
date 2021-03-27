require_relative 'env'

class MarketMakingBot

  Order = Struct.new :side, :amount, :price, :coin, keyword_init: true

  CONF = {
    side:   :buy,
    price:  "0.000035",   # cheap cheapETHs :D (price treshold, take only at this price)
    amount: "50",         # amount to buy (per hour) in cheapETHs
    every:  "60",         # trigger an order every x minutes if the market is at that price level
    auto_stop_after: "3", # automatically shut off after x days
    coin:   :CTH          # CTH/ETH pair
  }


  FIVE_MINUTES = 60 * 5 # seconds

  Sms = SMS.new

  def check_for_new_orders
    amount = 0
    price = 0
    last_order = Order.new(
      amount: amount,
      price:  price,
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
    Centex.place_order order: order
  end

  def create_matching_order(last_order:)
    side_match = order_match.fetch :side
    side = side_match == :sell ? :buy : :sell
    Order.new(
      side:   CONF.fetch(:side),
      amount: CONF.fetch(:amount),
      price:  CONF.fetch(:price),
      coin:   CONF.fetch(:coin),
    )
  end

  def main_tick
    last_order = check_for_new_orders
    order = create_order last_order: last_order
    send_sms_alert order: order
    place_order order: last_order
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
  bot = MarketMakingBot.new
  bot.main_loop
end
