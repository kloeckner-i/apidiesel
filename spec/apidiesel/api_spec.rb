describe Apidiesel::Api do
  describe 'Integration' do
    # the next  section tries to simulate the use of Apidiesel
    # to a degree
    let(:api_class) { FoolishApi::MyApi }
    before do
      # there is no documentation for this
      module Handlers
        # dummy class for a simple request handler
        class RequestHandler
          def run(request, _)
            request.response_body = "foobar"
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
      FoolishApi::MyApi.register_actions
    end

    it 'makes a request against https://foor.bar.com/users' do
      api = api_class.new
      api.get_users
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
