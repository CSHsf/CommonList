require "rvm/capistrano"
require "rvm/capistrano/alias_and_wrapp"
require 'bundler/capistrano'
require 'capistrano-unicorn'

role :app, "dev.lists.delaha.us"

set :deploy_to, "/var/www/dev.lists.delaha.us"
set :deploy_via, :remote_cache

set :user, "dev-commonlist-deployer"

set :rvm_ruby_string, :local

set :unicorn_pid, "/var/tmp/#{application}.pid"
set :unicorn_env, :staging
set :unicorn_config_rel_path, "config/unicorn"

set :rails_env, :staging

before "deploy:setup",         "rvm:install_rvm"
before "deploy:setup",         "rvm:install_ruby"
before "deploy:setup", "rvm:create_alias"
before "deploy:setup", "rvm:create_wrappers"
