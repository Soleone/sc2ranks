module SC2Ranks
  
  class API
    class NoCharacterError < StandardError
    end
    
    include HTTParty
    
    REGIONS = %w[ us eu kr tw sea ru la ]
    SEARCH_TYPES = [ :exact, :contains, :starts, :ends ]

    self.class.send(:attr_accessor, :debug)
    self.debug = false
    
    base_uri "http://sc2ranks.com/api"
    default_params :appKey => APP_KEY
    
    def search(name, region = REGIONS.first, type = :exact, offset = nil)
      url = "/search/#{type}/#{region}/#{name}"
      url += "/#{offset}" if offset
      result = get(url)
      Characters.new(result.parsed_response)
    end
    
    def find(name, region = REGIONS.first)
      characters = search(name, region)
      char = characters.first
      base_character(name, char.bnet_id, region)
    end
    
    def base_character(name, code, region = REGIONS.first)
      result = get("/base/char/#{region}/#{encoded_name(name, code)}")
      Character.new(result.parsed_response)
    end
    
    
    private
    
    def encoded_name(name, code)
      code_type = code.to_s.size == 3 ? '$' : '!'
      "#{name}#{code_type}#{code}"
    end
    
    def get(path, format = :xml, options = {})
      response = self.class.get(path, options)
      if self.class.debug
        puts path 
        puts response.inspect
      end
      
      raise NoCharacterError if response['error'] == "no_characters"
      response
    end
  end
  
end
