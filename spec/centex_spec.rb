require_relative "spec_helper"

describe "Centex" do

  let (:centex) { Centex.new }

  before do
    allow(centex).to receive(:tickers_get) {
      [{"ticker_id":"CTH-ETH","base_currency":"CTH","target_currency":"ETH","last_price":"0.00004000","base_volume":"93.00000000","target_volume":"0.00314600","bid":"0.00002000","ask":"0.00004000","high":"0.00004000","low":"0.00002000"},{"ticker_id":"REA-BTC","base_currency":"REA","target_currency":"BTC","last_price":"0.00000005","base_volume":"0.00000000","target_volume":"0.00000000","bid":"0.00000001","ask":"0.00000005","high":"0.000000","low":"0.00000000"}].to_json
    }
  end

  specify "gets ticker price (mid price)" do
    mid_price = 0.00003
    price = centex.ticker symbol: :CTH
    price.should == mid_price
  end

end
