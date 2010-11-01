require 'helper'

class TestSc2ranks < Test::Unit::TestCase
  API_KEY = 'http://github.com/coderjoe/sc2ranks'

  context "A SC2Ranks::API base request by bnet_id" do
    setup do
      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true

      @character = @api.get_character('coderjoe',298901)
    end

    should "return a SC2Ranks::Character on base request" do
      assert_instance_of SC2Ranks::Character, @character
    end

    should "find the correct character" do
      assert_equal "coderjoe", @character.name
      assert_equal 630, @character.character_code
      assert_equal 298901, @character.bnet_id
      assert_equal 'us', @character.region
    end
  end

  context "A SC2Ranks::API base request by character code" do
    setup do
      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true

      @character = @api.get_character('coderjoe',630)
    end

    should "return a SC2Ranks::Character on base request" do
      assert_instance_of SC2Ranks::Character, @character
    end

    should "find the correct character" do
      assert_equal "coderjoe", @character.name
      assert_equal 630, @character.character_code
      assert_equal 298901, @character.bnet_id
      assert_equal 'us', @character.region
    end
  end

  context "A SC2Ranks::API base" do
    setup do
      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true
    end

    should "raise \"NoCharacter\" when no such character found" do
      assert_raises SC2Ranks::API::NoCharacterError do
        @api.get_character('asdfghjklasdfghjklasdfghjklasdfghjkl',12345678);
      end
    end
  end

  context "A SC2Ranks::API base with teams request" do
    setup do
      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true
    end
    
    should "return team info" do
      character = @api.get_team_info( 'coderjoe', 298901 )
      assert_instance_of Array, character.teams
      assert character.teams.size > 0
    end

    should "raise NoCharacterError when no characters are found" do
      assert_raises SC2Ranks::API::NoCharacterError do
        character = @api.get_team_info( 'asdfghjklasdf', 123456789 )
      end
    end
  end

  context "A SC2Ranks::API mass base request" do
    setup do
      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true

      @characters = []
      @characters << {:name => 'coderjoe', :bnet_id => 298901, :region=>'us'}
      @characters << {:name => 'dayvie', :bnet_id => 715900,:region=>'us'}
      @characters << {:name => 'HuK', :bnet_id => 388538,:region=>'us'}
    end

    should "return multiple characters at once" do
      response = @api.get_mass_characters( @characters )

      assert_instance_of SC2Ranks::Characters, response
    end

    should "raise no NoCharacterError if one of the characters doesn't exist" do
      @characters << {:name => 'asdfghjkasdfghjk', :bnet_id => 123456789, :region => 'us'}

      assert_raises SC2Ranks::API::NoCharacterError do
        response = @api.get_mass_characters( @characters )
      end
    end

    should "raise TooManyCharactersError when more than 100 characters are provided" do
      too_many_chars = []
      (1..102).each do |i|
        too_many_chars << {:name => "coderjoe#{i}", :bnet_id => 298901, :region => 'us' }
      end

      assert_raises SC2Ranks::API::TooManyCharactersError do 
        response = @api.get_mass_characters( too_many_chars )
      end
    end
  end
end
