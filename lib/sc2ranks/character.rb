module SC2Ranks

  class Character < Struct.new(:name, :bnet_id, :character_code, :region, :updated_at, :achievement_points, :portrait, :teams)    
    def initialize(hash)
      members.each do |member|
        self[member] = hash[member.to_s]
      end
    end
  end
 
  # Wraps array like responses from the API
  #
  # If the total attribute doesn't match the array length
  # then there are more characters to be fetched if required
  class Characters < DelegateClass(Array)
    include Enumerable
    attr_reader :characters, :total
    
    def initialize(arg)
      if arg.is_a?(Array)
        @total = arg.length
        @characters = []
        arg.each do |char|
          @characters << Character.new(char)
        end
      elsif arg.is_a?(Hash)
        @characters = arg['characters'].map{ |char| Character.new(char) }
        @total = arg['total']
      end
      super(@characters)
    end
  end

end
