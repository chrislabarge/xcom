require 'socket'
require 'uri'
require 'cgi'
require_relative 'turn'

module Xcommy
  class Server
    attr_accessor :turns

    def initialize
      @turns = []
    end

    def url
      "#{ip}:8080"
    end

    def ip
      @ip ||= Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
    end

    def run
      @tcp_server = TCPServer.new(ip, 8080)

      while true do
        client = @tcp_server.accept
        request = client.readpartial(2048)

        client.write(generate_response(request))
      end
    end

    private

    def generate_response(request)
      request_data = parse_request(request)
      uri = URI.parse(request_data[:path])

      if request_data[:method] == "POST"
        params = CGI::parse(request.lines.last)

        return response("ok") if params["id"].nil?

        @turns << Turn.new(resource_params(params))
      else
        if uri.path.include?("start")
          if @ready_to_play
            return response("ready")
          else
            return response("not", code: 402)
          end
        end

        params = CGI::parse(uri.query)

        return response("ok") if params["id"].nil?

        turn_id = params["id"].last&.to_i

        @ready_to_play = true

        unless turns.map(&:id).include?(turn_id.to_i)
          return response("Waiting", code: 204)
        end
      end

      response(@turns.last.to_json)
    end

    def resource_params(data)
      content = {
        id: data["id"].last.to_i,
        type: data["type"].last&.to_sym,
      }

      if data["player_index"].last.nil?
        content[:position] =
          [data["position_y"].last.to_i, data["position_x"].last.to_i]
      else
        content[:player_index] = data["player_index"].last.to_i
      end

      if content[:type] == :hit
        content[:damage] = data["damage"].last.to_i
      end

      content
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
end
