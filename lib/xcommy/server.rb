require 'socket'
require 'uri'
require 'cgi'
require_relative 'turn'

module Xcommy
  class Server
    def initialize
      @turns = []
    end

    def run
      server = TCPServer.new("localhost", 8080)

      loop do
        client = server.accept
        request = client.readpartial(2048)

        client.write(generate_response(request))
      end
    end

    private

    def generate_response(request)
      request_data = parse_request(request)
      uri = URI.parse(request_data[:path])

      if uri.query
        params = CGI::parse(uri.query)

        if request_data[:method] == "POST"
          @turns << Turn.new(resource_params(params))
        else
          turn_id = params["id"].last&.to_i
          unless @turns.map(&:id).include?(turn_id)
            return response("Waiting")
          end
        end

        content = @turns.last.to_json
      end

      response(content)
    end

    def resource_params(data)
      {
        id: data["id"].last.to_i,
        player_index: data["player_index"].last.to_i,
        type: data["type"].last.to_sym,
        position: [data["position_y"].last.to_i, data["position_x"].last.to_i],
      }
    end

    def parse_request(request)
      method, path, _version = request.lines[0].split
      {
        path: path,
        method: method,
      }
    end

    def response(content, code: 200)
      "HTTP/1.1 #{code}\r\n" +
        "Content-Length: #{content.size}\r\n" +
        "\r\n" +
        "#{content}\r\n"
    end
  end

  Server.new.run
end
