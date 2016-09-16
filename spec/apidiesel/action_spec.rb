describe Apidiesel::Action do
  let(:action) { Class.new(described_class) }

  describe 'class methods' do
    describe '.endpoint' do
      it 'sets the endpoint' do
        expect { action.endpoint '/foo' }.to change { action.endpoint }.to '/foo'
      end
    end

    describe '.name_as_method' do
      it 'returns an appropriate name based on the class name' do
        Foo = Class.new(described_class)
        expect(Foo.name_as_method).to eql('foo')
      end
    end

    describe '.http_method' do
      it 'sets the http method for this action' do
        expect { action.http_method(:options) }.to change { action.http_method }.to :options
      end
    end

    describe '.url' do
      it 'fails when being given a URI with args' do
        expect { action.url('http://foobar.com', { foo: 4, bar: 2 }) }.to raise_error(ArgumentError)
      end
    end
  end
end
