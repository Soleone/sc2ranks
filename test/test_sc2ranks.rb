require 'helper'

class TestSc2ranks < Test::Unit::TestCase

  context "A SC2Ranks::API base request by bnet_id" do
    setup do
      @api = SC2Ranks::API.new
      SC2Ranks::API.debug = true

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
      @api = SC2Ranks::API.new
      SC2Ranks::API.debug = true

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
      @api = SC2Ranks::API.new
      SC2Ranks::API.debug = true
    end

    should "raise \"NoCharacter\" when no such character found" do
      assert_raises SC2Ranks::API::NoCharacterError do
        @api.get_character('asdfghjklasdfghjklasdfghjklasdfghjkl',12345678);
      end
    end
  end

  context "A SC2Ranks::API base with teams request" do
    setup do
      @api = SC2Ranks::API.new
      SC2Ranks::API.debug = true
    end
    
    should "return team info" do
      character = @api.get_team_info( 'coderjoe', 298901 )
      assert_instance_of Array, character.teams
      assert character.teams.size > 0
    end

    should "raise NoCharacterError when no characters are found" do
      assert_raises NoCharacterError do
        character = @api.get_team_info( 'asdfghjklasdfghjklasdfghjkl', 1234567891234567890 )
      end
    end
  end
end
