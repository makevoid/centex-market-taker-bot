CONF = {
  side:   "buy",
  price:  0.000043,   # minimum price to buy at
  amount: 1,          # amount to buy (per hour) in cheapETHs
  # amount: "50",     # amount to buy (per hour) in cheapETHs
  every:  60,         # trigger an order every x minutes if the market is at that price level
  auto_stop_after: 3, # automatically shut off after x days
  coin:   :CTH        # CTH/ETH pair
}
