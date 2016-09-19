describe Apidiesel::Handlers do
  describe Apidiesel::Api do
    describe 'use' do
      it 'registers a Request/Response/ExceptionHandler for the class using the Api' do
        Foo::RequestHandler = Class.new
        Foo::ResponseHandler = Class.new
        Foo::ExceptionHandler = Class.new

        MyApi = Class.new(Apidiesel::Api) do
          use Foo # mock handler, Apidiesel will look for Foo::RequestHandler, a.s.f
        end

        expect(MyApi.request_handlers.length).to eql 1
        expect(MyApi.response_handlers.length).to eql 1
        expect(MyApi.exception_handlers.length).to eql 1

        expect(MyApi.request_handlers.first).to be_a Foo::RequestHandler
        expect(MyApi.response_handlers.first).to be_a Foo::ResponseHandler
        expect(MyApi.exception_handlers.first).to be_a Foo::ExceptionHandler
      end
    end

    describe 'Handlers' do
      describe 'interface' do
        before do
          module Handlers
            # a demo for a request handler
            class RequestHandler
              def run(request, api_config)
                api_config[:foo] = 'bar'
                request
              end
            end

            # a demo for a ResponseHandler
            class ResponseHandler
              def run(request, api_config)
                api_config[:bar] = 'foo'
                request
              end
            end

            # a demo for an ExceptionHandler
            class ExceptionHandler
              def run(error, request, api_config)
                request.error = error
                api_config[:baz] = 'foobar'
                request
              end
            end
          end
          MyApi = Class.new(Apidiesel::Api) do
            use Handlers
          end
        end

        it 'registers all the handlers' do
          expect(MyApi.request_handlers.length).to eql 1
          expect(MyApi.response_handlers.length).to eql 1
          expect(MyApi.exception_handlers.length).to eql 1
        end
      end
    end
  end
end
