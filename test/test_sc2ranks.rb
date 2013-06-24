require 'helper'

class TestSc2ranks < Test::Unit::TestCase
  API_KEY = 'http://github.com/coderjoe/sc2ranks?gemtestsuite'

  context "A character base request by bnet_id" do
    setup do
      VCR.insert_cassette('character_request_by_bnet_id',:record => :new_episodes)
      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true

      @character = @api.get_character('coderjoe',298901)
    end

    teardown do
      VCR.eject_cassette
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

  context "A character base request by character code" do
    setup do
      VCR.insert_cassette('character_request_by_character_code', :record => :new_episodes)

      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true

      @character = @api.get_character('coderjoe',630)
    end

    teardown do
      VCR.eject_cassette
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
      VCR.insert_cassette('base_requests', :record => :new_episodes )

      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true
    end

    teardown do
      VCR.eject_cassette
    end

    should "raise \"NoCharacter\" when no such character found" do
      assert_raises SC2Ranks::API::NoCharacterError do
        @api.get_character('asdfghjklasdfghjklasdfghjklasdfghjkl',12345678);
      end
    end
  end

  context "A character base with teams request" do
    setup do
      VCR.insert_cassette('base_with_teams',:record => :new_episodes)
      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true
    end

    teardown do
      VCR.eject_cassette
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

  context "A mass base request" do
    setup do
      VCR.insert_cassette('mass_base_request', :record => :new_episodes)
      @api = SC2Ranks::API.new(API_KEY)
      #SC2Ranks::API.debug = true

      @characters = []
      @characters << {:name => 'coderjoe', :bnet_id => 298901, :region=>'us'}
      @characters << {:name => 'dayvie', :bnet_id => 715900,:region=>'us'}
      @characters << {:name => 'HuK', :bnet_id => 388538,:region=>'us'}
    end

    teardown do
      VCR.eject_cassette
    end

    should "return multiple characters at once" do
      response = @api.get_mass_characters( @characters )

      assert_instance_of SC2Ranks::Characters, response
    end

    should "raise no NoCharacterError if no characters are requested" do
      @characters << {:name => 'asdfghjkasdfghjk', :bnet_id => 123456789, :region => 'us'}

      assert_raises SC2Ranks::API::NoCharacterError do
        response = @api.get_mass_characters( [] )
      end
    end

    should "raise TooManyCharactersError when more than 100 characters are provided" do
      too_many_chars = []
      (1..101).each do |i|
        too_many_chars << {:name => "user#{i}", :bnet_id => i, :region => 'us' }
      end

      assert_raises SC2Ranks::API::TooManyCharactersError do 
        response = @api.get_mass_characters( too_many_chars )
      end
    end
  end

  context "When performing an exact search" do
    setup do
      VCR.insert_cassette('exact_search',:record => :new_episodes)
      @api = SC2Ranks::API.new(API_KEY)
      @characters = @api.search('shadow','us',:exact)
    end

    teardown do
      VCR.eject_cassette
    end

    should "be of type SC2Rank::Characters" do
      assert_instance_of SC2Ranks::Characters, @characters
    end

    should "return more than one result" do
      assert @characters.length > 1
    end

    should "all be named have the same name" do
      #Warning, this test is bad.
      #This search will return a good many results.
      #and there's no way we can check them all without being very mean to the sc2ranks server
      #unless we want to rate limit... but then we are spending a lot of time waiting for tests.
      #
      #Ideas anybody?
      @characters.each do | i |
        assert i.name.downcase == 'shadow', "#{i.name} is not 'shadow'"
      end
    end

    should "raise NoCharacterError when no characters found" do
      assert_raises SC2Ranks::API::NoCharacterError do
        @api.search('asdfghjklasdfghjkl')
      end
    end
  end

  context "When performing a find" do
    setup do
      VCR.insert_cassette('find',:record => :new_episodes)

      @api = SC2Ranks::API.new(API_KEY)
      @character = @api.find('coderjoe')
    end

    teardown do
      VCR.eject_cassette
    end

    should "be return a Character instance" do
      assert_instance_of SC2Ranks::Character, @character
    end

    should "find the correct character" do
      assert_equal 'coderjoe', @character.name
    end

    should "raise NoCharacterError when no character is found" do
      assert_raises SC2Ranks::API::NoCharacterError do
        @api.find('asdfghjkasdfghjkl')
      end
    end
  end
end
