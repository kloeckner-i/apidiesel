describe Apidiesel::Api do
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
