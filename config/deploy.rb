# encoding: utf-8

require 'bundler/capistrano'

begin
  # cannot use Rails.env 'cause Rails not found
  config = YAML.load(File.read(File.expand_path("./application.yml", File.dirname(__FILE__) )))
  config.each do |key, value|
    ENV[key] = value unless value.kind_of? Hash
  end
rescue => e
  raise e
end


###########################
## Capistrano Utilities
###########################


# SSHの詳細なログを出す
#ssh_options[:verbose] = :debug

# capistranoの出力がカラーになる
require 'capistrano_colors'
# cap deploy時に自動で bundle install が実行される
require "bundler/capistrano"

###########################
##  rbenv
###########################

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

###########################

# to chef
load "config/recipes/base"
load "config/recipes/database"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/check"

set :user,      ENV["REMOTE_USER"]
set :password,  ENV["REMOTE_PASSWORD"]
set :rails_env, "production"
set :branch, "master"
role :web, ENV["REMOTE_HOST"]
role :app, ENV["REMOTE_HOST"]
role :db,  ENV["REMOTE_HOST"], :primary => true

set :application, ENV["APPLICATION_NAME"]
set :deploy_to, "/var/www/rails/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository,  ENV["REPOSITORY"]

set :git_enable_submodules, 1

# uplaod dir to statics
# set :shared_children, shared_children + %w{public/uploads}

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :keep_releases, 2
after "deploy", "deploy:cleanup" # keep only the last 5 releases

# Unicorn用に起動/停止タスクを変更
namespace :deploy do
  desc "Load the seed data from db/seeds.rb"
  task :seed, role: :db do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end

  task :after_update_code do
    %w{documents uploads}.each do |share|
      run "ln -s #{shared_path}/#{share} #{release_path}/public/#{share}"
    end
    %w{database.yml environment.rb}.each do |config|
      run "ln -nfs #{shared_path}/#{config} #{release_path}/config/#{config}"
    end
  end
end