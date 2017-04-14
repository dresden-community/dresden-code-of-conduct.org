#require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'dresden-code-of-conduct.org'
set :deploy_to, '/var/www/dresden-code-of-conduct.org'
set :repository, 'https://github.com/dresden-community/dresden-code-of-conduct.org.git'
set :branch, 'master'
set :keep_releases, 3

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
#set :shared_paths, ['config/database.yml', 'log']

# Optional settings:
   set :user, 'deploy'  # Username in the server to SSH to.
#  set :port, '22'     	# SSH port number.


desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'reload_env'
    on :launch do
      invoke :'deploy:cleanup'
    end
  end
end

desc "Reloading nginx and php-fpm"
task :reload_env do
    command 'sudo service nginx reload'
end

desc "Rolls back the latest release"
task :rollback => :environment do
  queue! %[echo "-----> Rolling back to previous release for instance: #{domain}"]

  # Delete existing sym link and create a new symlink pointing to the previous release
  command %[echo -n "-----> Creating new symlink from the previous release: "]
  command %[ls "#{deploy_to}/releases" -Art | sort | tail -n 2 | head -n 1]
  command! %[ls -Art "#{deploy_to}/releases" | sort | tail -n 2 | head -n 1 | xargs -I active ln -nfs "#{deploy_to}/releases/active" "#{deploy_to}/current"]

  # Remove latest release folder (active release)
  command %[echo -n "-----> Deleting active release: "]
  command %[ls "#{deploy_to}/releases" -Art | sort | tail -n 1]
  command! %[ls "#{deploy_to}/releases" -Art | sort | tail -n 1 | xargs -I active rm -rf "#{deploy_to}/releases/active"]
end
