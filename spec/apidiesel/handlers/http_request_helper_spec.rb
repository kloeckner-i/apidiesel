describe Apidiesel::Handlers::HttpRequestHelper do
  # test setup require a custom build api with an action
  module Handlers
    # dummy class for a simple request handler
    # includes a demo call (which is not implemented by this gem directly)
    # it simulates some failure
    class RequestHandler
      include Apidiesel::Handlers::HttpRequestHelper
      def run(request, config)
        execute_request(request: request, payload: {}, api_config: config)
      end
    end
  end

  module MoarFoolishApi
    MyApi = Class.new(Apidiesel::Api) do
      url 'https://foo.bar.com'
      retries 3
      use Handlers
    end

    module Actions
      GetUsers = Class.new(Apidiesel::Action) do
        http_method :get
        url path: '/users'
      end
    end
  end
  # create our dummy api once
  MoarFoolishApi::MyApi.register_actions

  it 'retries a request if it fails, when configured' do
    request = stub_request(:get, 'https://foo.bar.com/users')
              .to_raise(StandardError)
              .then
              .to_return(body: 'foo')

    MoarFoolishApi::MyApi.new.get_users
    expect(request).to have_been_made.twice
  end

  it 'fails when the retries have been used up' do
    request = stub_request(:get, 'https://foo.bar.com/users')
              .to_raise(StandardError)
    MoarFoolishApi::MyApi.retries 0
    expect { MoarFoolishApi::MyApi.new.get_users }.to raise_error(Apidiesel::RequestError)
    expect(request).to have_been_made.once
  end
end
