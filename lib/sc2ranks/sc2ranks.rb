module SC2Ranks
  VERSION = File.read(File.dirname(__FILE__) + "/../../VERSION")
  
  APP_KEY  = "SC2Ranks Ruby API #{VERSION}"
  
  # "name"=>"Soleone", 
  # "region"=>"us", 
  # "bnet_id"=>297997,
  # "updated_at"=>Fri Sep 24 06:02:40 UTC 2010,
  # "character_code"=>380,
  # "achievement_points"=>685,
  # "portrait"=>{"icon_id"=>2, "row"=>4, "column"=>3}  
  class Character < Struct.new(:name, :bnet_id, :character_code, :region, :updated_at, :achievement_points, :portrait)    
    def initialize(hash)
      members.each do |member|
        self[member] = hash[member]
      end
    end
  end
  
  class Characters < DelegateClass(Array)
    include Enumerable
    attr_reader :characters, :total
    
    def initialize(hash)
      @characters = hash['characters'].map{ |char| Character.new(char) }
      @total = hash['total']
      super(@characters)
    end
  end
end