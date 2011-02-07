require 'resque/server'
Resque::Server.use Rack::Auth::Basic do |username, password|
  username == 'tom'
  password == 'cr4zycr4zy'
end
