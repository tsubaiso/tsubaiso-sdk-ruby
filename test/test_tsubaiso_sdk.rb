require 'minitest/autorun'
require 'time'
require './lib/tsubaiso_sdk'

class TsubaisoSDKTest < Minitest::Test
  def setup
    @api = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })
  end

  def test_failed_request
    @api_fail = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: 'fake token' })
    sale = @api_fail.create_sale(@sale_201608)

    assert_equal 401, sale[:status].to_i, sale.inspect
    assert_equal 'Bad credentials', sale[:json][:error]
  end

  private

  def successful?(status)
    status.to_i == 200
  end
end
