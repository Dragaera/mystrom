# coding: utf-8

require 'json'

require 'httparty'

module MyStrom
  # Basic binding to the HTTP API exposed by MyStrom WLAN switches.
  #
  # @example Basic usage
  #   require 'mystrom'
  #
  #   w = MyStrom::WLANSwitch.new('http://10.60.1.10')
  #   puts "Current power throughput: #{ w.power }W"
  #   if w.power > 150
  #     puts "Using too much power, going dark."
  #     w.disable
  #   end
  #
  #   if rand() > 0.9
  #     puts "Messing with family - toggling floor lights."
  #     w.toggle
  #   end
  class WLANSwitch
    # Current power throughput in W
    # @return [Fixnum]
    attr_reader :power

    # If data should be refreshed after every operation
    # @return [Bool]
    attr_accessor :auto_refresh

    # HTTP URL of the switch
    # @return [String]
    attr_accessor :url

    # Initialize a new instance of the class.
    #
    # @param url [String] URL of the MySTrom WLAN Switch web interface.
    # @param opts [Hash] Additional options
    # @option opts [Bool] :auto_refresh (false) If data should be
    #   refreshed after every operation.
    def initialize(url, opts = {})
      @url = url
      @auto_refresh = opts.fetch(:auto_refresh, false)

      update_data
    end

    # Enable the relay.
    #
    # @raise [APIError] If the information returned by the API was missing or
    #   incomplete.
    # @return [Bool] New state of the relay.
    def enable
      do_request('relay?state=1')
      if auto_refresh
        update
      else
        @relay = true
      end

      @relay
    end

    # Disable the relay
    #
    # @raise [APIError] If the information returned by the API was missing or
    #   incomplete.
    # @return [Bool] New state of the relay.
    def disable
      do_request('relay?state=0')
      if auto_refresh
        update
      else
        @relay = false
      end

      @relay
    end

    # Toggle the relay.
    #
    # @raise [APIError] If the information returned by the API was missing or
    #   incomplete.
    # @return [Bool] New state of the relay.
    def toggle
      response = do_request('toggle')

      if auto_refresh
        update
      else
        begin
          data   = JSON.parse(response)
          @relay = data.fetch('relay')
        rescue JSON::ParserError => e
          raise APIError, "Returned JSON was not valid JSON (#{ e.message })"
        rescue KeyError => e
          raise APIError, "Returned JSON was missing required key (#{ e.message })"
        end
      end

      @relay
    end

    # Whether relay is enabled.
    def enabled?
      @relay
    end

    # Whether relay is disabled.
    def disabled?
      !@relay
    end

    # Refresh data.
    #
    # @raise [APIError] If the information returned by the API was missing or
    #   incomplete.
    # @return [WLANSwitch] self
    def update
      update_data

      self
    end

    private
    def update_data
      # TODO: Error handling
      begin
        data = JSON.parse(do_request('report'))
        @power = data.fetch('power')
        @relay = data.fetch('relay')
      rescue JSON::ParserError => e
        raise APIError, "Returned JSON was not valid JSON (#{ e.message })"
      rescue KeyError => e
        raise APIError, "Returned JSON was missing required key (#{ e.message })"
      end
    end

    def do_request(action)
      url = "#{ @url }/#{ action }"
      response = HTTParty.get(url)
      case response.code
      when 200
        response.body
      else
        raise APIError, "HTTP response invalid: Status code: #{ response.code }, Body: #{ response.body }"
      end
    end
  end
end
