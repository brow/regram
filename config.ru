# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'resque/server'

Resque::Server.use Rack::Auth::Basic do |username, password|
  username == 'brow' and password == 'cr4zycr4zy'
end

run Rack::URLMap.new \
  "/"       => Regram::Application,
  "/resque" => Resque::Server.new
