require 'test_helper'

class ApiTest < Test::Unit::TestCase
  def setup
    @api = SC2Ranks::API.new
    SC2Ranks::API.debug = true
  end
  
  def test_search_returns_characters_instance_which_is_an_array
    characters = @api.search("Soleone")
    assert_instance_of SC2Ranks::Characters, characters
    assert characters.is_a?(Enumerable)
  end

  def test_search_returns_character_instance
    characters = @api.search("Soleone")
    first = characters.first
    assert_instance_of String, first.name
    assert_instance_of Fixnum, first.bnet_id    
  end
  
  def test_search_returns_size_and_total
    characters = @api.search("Soleone")
    assert_instance_of Fixnum, characters.size
    assert_instance_of Fixnum, characters.total    
  end
  
  def test_search_raises_error_when_no_character_found
    assert_raises SC2Ranks::API::NoCharacterError do
      @api.search("akdjalksjdalksjdkajshfkjsdhfkjlahs")
    end
  end

  def test_find_returns_character_instance
    character = @api.find("Soleone")
    assert_instance_of SC2Ranks::Character, character
    assert_equal "Soleone", character.name
    assert_equal "us", character.region
    assert_instance_of Fixnum, character.bnet_id
    assert_instance_of Fixnum, character.character_code
    assert_equal 3, character.character_code.to_s.length
    assert_instance_of Time, character.updated_at
    assert_instance_of Fixnum, character.achievement_points
    assert_instance_of Hash, character.portrait
  end
  
  def test_find_only_does_a_single_remote_call_when_character_code_is_provided
    # TODO: add expectation to verify that only a single remote call was made
    character = @api.find("Soleone", 380)
    assert_equal "Soleone", character.name
    assert_equal "us", character.region
  end
end