set :application, "regram"
set :repository,  "git@github.com:brow/regram.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/brow/public_html/regram"

role :web, "regr.am"                          # Your HTTP server, Apache/etc
role :app, "regr.am"                          # This may be the same as your `Web` server
role :db,  "regr.am", :primary => true        # This is where Rails migrations will run

set :user, "brow"
ssh_options[:forward_agent] = true            # Use local private key rather than regr.am's
default_run_options[:pty] = true              # Allows us to be prompted for sudo password

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    # Restart resque workers and scheduler
    run "#{try_sudo} god restart resque"
    
    # Touch restart.txt to restart Passenger
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end