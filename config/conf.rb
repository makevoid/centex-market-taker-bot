CONF = {
  side:   "buy",
  price:  "0.000035",   # cheap cheapETHs :D
  amount: "1",         # amount to buy (per hour) in cheapETHs
  # amount: "50",         # amount to buy (per hour) in cheapETHs
  every:  "60",         # trigger an order every x minutes if the market is at that price level
  auto_stop_after: "3", # automatically shut off after x days
}
