module MidPrice

  def mid_price(ticker)
    ask_price = BigDecimal ticker.fetch("ask")
    bid_price = BigDecimal ticker.fetch("bid")
    (ask_price + bid_price) / 2
  end

end
