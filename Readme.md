# centex-market-taker-bot

Simple market taker bot for cente - this bot can place buy orders that take (match) active market offers (sell orders)

#### Exchange:

Centex

API: https://api.centex.io/docs

#### Secrets:

the secret config file is `env_secret.rb`, copy the default one and fill in your centex exchange api key `cp env_secret.default.rb env_secret.rb`

#### Bot config:

```rb
{
  side: "buy",      # or "sell" - default: "buy"
  price:  "0.0001", # maximum price you want to match orders at
  amount: "50",     # amount to buy (per hour) in cheapETHs
  every:  "60",     # trigger an order every x minutes if the market is at that price level
  coin: "eth",      # or others listed # default: "eth"
}
```

#### Install dependencies:

    bundle

#### Run:

    bundle exec rake


---

License: The Unlicense

The program is provide it as is, this is not a finished product, use at your own risk.

----

@makevoid
