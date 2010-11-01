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
      url = "/base/char/#{region}/#{encoded_name(name,code)}.json"
      response = get_request(url)

      Character.new(response.parsed_response)
    end

    def get_team_info( name, code, region = REGIONS.first )
      url = "/base/teams/#{region}/#{encoded_name(name,code)}.json"
      response = get_request(url)

      Character.new(response.parsed_response)
    end

    def get_mass_characters( character_array )
      url = "/mass/base/char/"

      #Using the standard rails format query string for an array 
      # characters[][region]=us&characters[][name]=coderjoe&characters[][bnet_id]=12345
      # causes sc2ranks.com to error 500. We should follow their docs and add array indexes.
      #post_req = { :query => { :characters => character_array } }
      post_req = { :query => character_array_to_str_hash(character_array) }

      response = post_request(url, post_req )

      Characters.new(response.parsed_response)
    end

    private

    def character_array_to_str_hash( array )
      query_hash = {}

      array.each_index do |i|
        array[i].map do |key, val|
          query_hash["characters[#{i}][#{URI.encode(key.to_s)}]"] = URI.encode(val.to_s)
        end
      end

      query_hash
    end

    def raise_errors( response )
      if response.parsed_response.is_a?(Hash) && response.parsed_response.has_key?('error')
        raise NoKeyError if response['error'] == 'no_key'
        raise NoCharacterError if response['error'] == 'no_character' or response['error'] == 'no_characters'
        raise TooManyCharactersError if response['error'] == 'too_many_characters'
      end
    end

    def post_request( url, post_params = {} )
      response = self.class.post( url, post_params )
      raise_errors( response )

      response
    end

    def get_request( url, url_params = {} )
      response = self.class.get( url, url_params )
      raise_errors( response )

      response
    end

    def encoded_name(name, code)
      code_type = code.to_s.size == 3 ? '$' : '!'
      "#{name}#{code_type}#{code}"
    end
    
  end
  
end
