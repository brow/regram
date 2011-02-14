require 'resque_jobs'
require 'resque_scheduler'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
scheduler_config = YAML.load_file(rails_root + '/config/scheduler.yml')

Resque.redis = resque_config[rails_env]['redis']
Resque.schedule = scheduler_config