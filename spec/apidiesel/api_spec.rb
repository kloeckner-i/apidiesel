describe Apidiesel::Api do
  describe 'Integration' do
    # the next  section tries to simulate the use of Apidiesel
    # to a degree

    module Handlers
      # dummy class for a simple request handler
      # includes a demo call (which is not implemented by this gem directly)
      # it simulates some failure
      class RequestHandler
        def run(request, _)
          Net::HTTP.get(request.url)
          request.response_body = 'foobar'
          request
        end
      end
    end

    module FoolishApi
      MyApi = Class.new(Apidiesel::Api) do
        url 'https://foo.bar.com'
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
    FoolishApi::MyApi.register_actions

    it 'makes a request against https://foo.bar.com/users' do
      request = stub_request(:get, 'https://foo.bar.com/users')
      api = FoolishApi::MyApi.new
      api.get_users
      expect(request).to have_been_made.once
    end

    it 'allows for retrying when a request fails' do
      request = stub_request(:get, 'https://foo.bar.com/users')
                .to_timeout
                .then
                .to_raise(StandardError)
                .then
                .to_return(body: 'foobar')

      # set retries to three
      FoolishApi::MyApi.retries 3
      api = FoolishApi::MyApi.new

      api.get_users
      expect(request).to have_been_made.at_least_times(3)
    end

    it 'ignores retrying when a request is successful' do
      request = stub_request(:get, 'https://foo.bar.com/users')
                .to_return(body: 'foobar')

      # set retries to fifteen
      FoolishApi::MyApi.retries 15
      api = FoolishApi::MyApi.new

      api.get_users
      expect(request).to have_been_made.once
    end
  end

  describe 'DSL' do
    subject(:subject) { described_class }
    describe '.config' do
      it 'returns the config object for the API' do
        expect(subject.config).to be_a Hash
      end

      it 'sets arbitrary values for the config' do
        subject.config(:foo, 0)
        expect { subject.config(:foo, 42) }.to change { subject.config[:foo] }
          .from(0).to(42)
      end
    end

    describe '.retries' do
      it 'defaults to 0' do
        expect(subject.retries).to eql 0
      end

      it 'sets an amount of retries before raising an error' do
        expect { subject.retries 5 }.to change { subject.retries }.to 5
      end

      it 'can only set integers' do
        expect { subject.retries 5.5 }.to raise_error(ArgumentError)
        expect { subject.retries 'foo' }.to raise_error(ArgumentError)
      end
    end

    describe '.url' do
      let(:url) { 'https://foo.bar.com' }
      it 'sets the url as config' do
        expect { subject.url(url) }.to change { subject.config[:url] }
          .to(URI.parse(url))
      end

      it 'returns the url' do
        subject.url(url)
        expect(subject.url).to be_a URI
        expect(subject.url.to_s).to eql url
      end
    end

    describe '.http_basic_auth' do
      let(:user) { 'florian' }
      let(:password) { 'test1234' }

      it 'sets the username and password' do
        subject.http_basic_auth(user, password)
        expect(subject.config[:http_basic_username]).to eql user
        expect(subject.config[:http_basic_password]).to eql password
      end

      it 'returns the username and password' do
        subject.http_basic_auth(user, password)
        u, p = subject.http_basic_auth
        expect(u).to eql(user)
        expect(p).to eql(password)
      end
    end

    describe '.logger' do
      let(:logger) { Object.new }
      it 'sets a logger' do
        expect { subject.logger(logger) }.to change { subject.logger }.to logger
      end
    end
  end
end
