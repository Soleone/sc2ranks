# TODO: try without depending on rubygems
require 'rubygems'
require 'httparty'
require 'delegate'

$:.unshift(File.dirname(__FILE__))
require 'sc2ranks/sc2ranks'
require 'sc2ranks/api'