module Net #:nodoc: all
  class HTTP
    def request_get(path, &block)
      response = HTTPResponse.new
      response.body = File.new(path, 'r')
      yield response
    end
  end

  class HTTPResponse
    def initialize; end

    # Read the file one byte at a time
    def read_body(&block)
      while byte = @body.read(1)
        yield byte
      end
    end
  end
end