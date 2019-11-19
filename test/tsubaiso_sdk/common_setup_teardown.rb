module CommonSetupTeardown
  include WebMock::API

  def setup(resouce)
    WebMock.enable!
    WebMock.disable_net_connect!
    @api = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })
    StubRegister.new(
      resouce,
      @api.instance_variable_get(:@base_url),
      @api.instance_variable_get(:@access_token)
    )
  end

  def teardown
    WebMock.disable!
  end
end