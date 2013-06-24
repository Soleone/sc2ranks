require 'rubygems'
require 'test/unit'
require 'contest'
require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.http_stubbing_library = :fakeweb
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sc2ranks'

class Test::Unit::TestCase
end
