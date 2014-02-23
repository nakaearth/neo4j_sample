neo4j_url = ENV["GRAPHENEDB_URL"] || "http://localhost:7474" # default to local server

uri = URI.parse(neo4j_url)

require 'neography'

Neography.configure do |conf|
  conf.server = uri.host
  conf.port = uri.port
  conf.authentication = 'basic'
  conf.username = uri.user
  conf.password = uri.password
end
