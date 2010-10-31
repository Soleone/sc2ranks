module SC2Ranks

  class Character < Struct.new(:name, :bnet_id, :character_code, :region, :updated_at, :achievement_points, :portrait, :teams)    
    def initialize(hash)
      members.each do |member|
        self[member] = hash[member.to_s]
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
