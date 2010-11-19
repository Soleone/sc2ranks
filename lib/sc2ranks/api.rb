module SC2Ranks
  
  class API
    #HTTParty Setup
    include HTTParty
    base_uri "http://sc2ranks.com/api"
    format :json

    # The application key is the domain on which the sc2ranks data will be used
    attr_accessor :app_key

    # Create a new instance of the SC2Ranks::API with the given applciation key
    # Provide the domain you will be using the sc2ranks.com data on as your application key.
    #
    # Go to http://sc2ranks.com/api for more api restrictions
    def initialize( app_key )
      @app_key = app_key
    end

    # NoKeyError
    # This error is raised when no APP_KEY is provided
    class NoKeyError < StandardError
    end

    # NoCharacterError
    # This error is raised when a requested character can not be found
    # or when no characters are submitted for a get_mass_characters call
    class NoCharacterError < StandardError
    end

    # TooManyCharactersError
    # This error is raised when too many characters are requested durring
    # a get_mass_characters call.
    class TooManyCharactersError < StandardError
    end

    #Valid regions on battle.net
    REGIONS = %w[ us eu kr tw sea ru la ]

    #The search types available for use
    SEARCH_TYPES = [ :exact, :contains, :starts, :ends ]

    self.class.send(:attr_accessor, :debug)
    self.debug = false

    # get_character
    # Get the basic character info for a single character
    def get_character( name, code, region = REGIONS.first )
      url = "/base/char/#{region}/#{encoded_name(name,code)}.json"
      response = get_request(url)

      Character.new(response.parsed_response)
    end

    # get_team_info
    # Get the basic character info for a single character and include team (league)
    # information
    def get_team_info( name, code, region = REGIONS.first )
      url = "/base/teams/#{region}/#{encoded_name(name,code)}.json"
      response = get_request(url)

      Character.new(response.parsed_response)
    end

    # get_mass_characters
    # Return many sets of base character info in one lump request
    # character_array should be an array of character hashes in the form of
    # 
    #   { :name => 'coderjoe', :bnet_id => '1234567', :region => 'us' }
    #
    # The name, bnet_id, and region are all required parameters.
    # The bnet_id is required, you can not use character_code
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

    # search
    # Search for a character by name and region
    # The response is a hash of character name and bnet_id
    # Further information should be fetched using get_character
    def search(name, region = REGIONS.first, type = :exact, offset = nil)
      url = "/search/#{type.to_s}/#{region}/#{name}.json"
      url += "/#{offset}" if offset

      result = get_request(url)

      Characters.new(result.parsed_response)
    end

    # find
    # If no code is provided, return the base character info for the first 
    # character treturned by an exact search by name
    #
    # If the code is provided this call is identical to get_character
    def find(name, code = nil, region = REGIONS.first)
      if !code
        characters = search(name, region, :exact)
        code = characters.first.bnet_id
      end

      get_character(name,code,region)
    end

    private

    # character_array_to_str_hash
    # The sc2ranks API requires posted arrays to have indexes
    #   characters[0][name]=coderjoe&characters[0][bnet_id]=1234567&characters[0][region]=us
    #
    # Unfortunately HTTParty's parameter normalization omits the integer indexes.
    #   characters[][name]=coderjoe&characters[][bnet_id]=1234567&characters[][region]=us
    #   
    # This is supposidly fine for Rails, but not ok for sc2ranks.com's API.
    # This function converts an array of characters to a properly indexed hash
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
      elsif response.response.is_a?(Net::HTTPBadRequest)
        #sc2ranks doesn't follow their documentation right now.
        #sending over 100 characters results in a HTTP 400 BadRequest error.
        raise TooManyCharactersError
      end
    end

    def set_param_defaults( params )
      query_defaults = { 'appKey' => @app_key }

      if( params.has_key?(:query) )
        params[:query] = query_defaults.merge(params[:query])
      else
        params[:query] = query_defaults
      end

      params
    end

    # post_response
    # Wrapper around HTTParty post with library specific logic
    def post_request( url, post_params = {} )
      post_params = set_param_defaults(post_params)
      response = self.class.post( url, post_params )

      if self.class.debug
        puts "Url: #{url}"
        puts "Params: #{post_params.inspect}"
        puts "Response: #{response.inspect}"
      end

      raise_errors( response )

      response
    end

    # post_response
    # Wrapper around HTTParty post with library specific logic
    def get_request( url, url_params = {} )
      url_params = set_param_defaults(url_params)
      response = self.class.get( url, url_params )
      
      if self.class.debug
        puts "Url: #{url}"
        puts "Params: #{url_params.inspect}"
        puts "Response: #{response.inspect}"
      end

      raise_errors( response )

      response
    end

    # encoded_name
    # Turn a name/code combo into the correct URL name for use in the API
    #
    # names used with character_code should be $ delimited (i.e. name$123)
    # names used with bnet_id should be ! delimited (i.e. name!1234567)
    def encoded_name(name, code)
      code_type = code.to_s.size == 3 ? '$' : '!'
      "#{name}#{code_type}#{code}"
    end
    
  end
  
end
