CONF = {
  side:   "buy",
  price:  0.000043,   # minimum price to buy at
  amount: 20,          # amount to buy (per hour) in cheapETHs
  # amount: "50",     # amount to buy (per hour) in cheapETHs
  every:  6,          # trigger an order every 6 minutes if the market is at that price level (trigger max 10 times per hour - maximum buy is 200 cTH per hour with this config)
  auto_stop_after: 3, # automatically shut off after x days - not implemented
  coin:   :CTH        # CTH/ETH pair
}
