set :stages, %w{staging production}
set :default_stage, "staging"

require 'capistrano/ext/multistage'
require 'capistrano-tags'

default_run_options[:pty]   = true
ssh_options[:forward_agent] = true

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'

set :application, 'redmine'

set :rvm_ruby_string, 'ree@redmine'

set :use_sudo, false

set :keep_releases, 3

set :scm, :git
set :repository, "git://github.com/edavis10/redmine.git"
set :branch, '1.2.1'

set :deploy_via, :remote_cache

after 'deploy:setup', 'config:setup'
after 'deploy:setup', 'setup:gems'

namespace :deploy do
  task :default do
    update
    transaction do
      update_code
      delete_files_dir
      finalize_update
      config.upload
      migrate
    end
    restart
  end

  task :start do
    run "cd #{latest_release}; thin -C config/thin.yml -c #{latest_release} start"
  end

  task :stop do
    run "cd #{latest_release}; thin -C config/thin.yml -c #{latest_release} stop"
  end

  task :restart do
    stop
    start
  end

  task :delete_files_dir do
    puts "Deleting files directory..."
    run "cd #{latest_release}; rm -rf files"
  end
end

namespace :config do
  task :setup do
    run "mkdir -p #{deploy_to}/shared/config"
    run "mkdir -p #{deploy_to}/shared/files"
  end

  desc 'Upload configuration file to server'
  task :upload do
    Dir["config/*.#{rails_env}"].each { |entry|
      if File.file?(entry)
        system "scp #{entry} #{user}@#{server_name}:#{deploy_to}/shared/config/#{File.basename(entry, ".#{rails_env}")}"
      end
    }
  end

  after 'config:upload', 'config:update_symlinks'

  task 'update_symlinks' do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
    run "ln -nfs #{shared_path}/config/thin.yml #{latest_release}/config/thin.yml"
    run "ln -nfs #{shared_path}/config/configuration.yml #{latest_release}/config/configuration.yml"

    if rails_env == "staging"
      run "ln -nfs #{latest_release}/config/environments/production.rb #{latest_release}/config/environments/staging.rb"
    end

    run "ln -nfs #{shared_path}/files #{latest_release}/files"
  end

  after 'config:update_symlinks', 'config:generate_session_store'

  task 'generate_session_store' do
    run "cd #{latest_release}; rake generate_session_store"
  end
end

Gems = {
  "rake"   => "0.8.7",
  "rails"  => "2.3.11",
  "rack"   => "1.1.1",
  "mysql2" => "0.3.7",
  "i18n"   => "0.4.2",
  "thin"   => "1.2.11"
}

namespace :setup do
  desc 'Setup all necessary gems'
  task :gems do
    gems_command = Gems.inject(""){ |a,e| a += "gem install #{e[0]} -v=#{e[1]} --no-ri --no-rdoc;" }
    run "cd #{deploy_to}; #{gems_command}"
  end
end
