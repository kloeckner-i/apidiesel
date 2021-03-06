module Apidiesel
  module Handlers
    module MockResponse
      class RequestHandler
        def run(request, api_config)
          action = request.action

          return request unless action.respond_to?(:mock_response) && action.mock_response

          file_name = action.mock_response[:file]
          parser    = action.mock_response[:parser]
          file      = File.read(file_name)

          request.response_body = if parser
            parser.call(file)

          elsif file_name.ends_with?('.json')
            JSON.parse(file)

          elsif file_name.ends_with?('.xml')
            Hash.from_xml(file)

          else
            file
          end

          request
        end
      end

      module ActionExtension
        extend ActiveSupport::Concern

        class_methods do
          def mock_response!(file:, &block)
            @mock_response = {
              file: file,
              parser: block
            }
          end

          def mock_response
            @mock_response
          end
        end

        def mock_response
          self.class.mock_response
        end
      end
    end
  end
end

Apidiesel::Action.send(:include, Apidiesel::Handlers::MockResponse::ActionExtension)