module SC2Ranks

  # Character class
  #
  # This class wraps the various properties of returned character data
  class Character < Struct.new(:name, :bnet_id, :character_code, :region, :updated_at, :achievement_points, :portrait, :teams)    
    def initialize(hash)
      members.each do |member|
        self[member] = hash[member.to_s]
      end
    end
  end
  
  # Characters class
  #
  # This class wraps array like responses from the API
  # into an object which acts much like an array.
  #
  # @total Represents the total number of available characters in the request
  # This may or may not be the same as the number of charactes present in the Characters class.
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
