module SC2Ranks
  
  class API
    #HTTParty Setup
    include HTTParty
    base_uri "http://sc2ranks.com/api"
    default_params :appKey => APP_KEY
    format :json

    #Define Errors
    class NoKeyError < StandardError
    end

    class NoCharacterError < StandardError
    end

    class TooManyCharactersError < StandardError
    end

    #Class Constants
    REGIONS = %w[ us eu kr tw sea ru la ]
    SEARCH_TYPES = [ :exact, :contains, :starts, :ends ]
    
    self.class.send(:attr_accessor, :debug)
    self.debug = false

    def get_character( name, code, region = REGIONS.first )
      url = "/base/char/#{region}/#{encoded_name(name,code)}"
      response = api_request(url)

      Character.new(response.parsed_response)
    end

    def get_team_info( name, code, region = REGIONS.first )
      url = "/base/char/#{region}/#{encoded_name(name,code)}"
      response = api_request(url)

      Character.new(response.parsed_response)
    end

    private

    def api_request( url, url_params = {} )
      request_url = "#{url}.json"
      response = self.class.get( request_url, url_params )

      if( self.class.debug )
        puts request_url
        puts response.inspect
      end

      raise NoKeyError if response['error'] == 'no_key'
      raise NoCharacterError if response['error'] == 'no_character' or response['error'] == 'no_characters'
      raise TooManyCharactersError if response['error'] == 'too_many_characters'

      response
    end

    def encoded_name(name, code)
      code_type = code.to_s.size == 3 ? '$' : '!'
      "#{name}#{code_type}#{code}"
    end
    
  end
  
end
