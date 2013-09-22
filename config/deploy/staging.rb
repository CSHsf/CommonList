require 'bundler/capistrano'
require "rvm/capistrano"
require 'capistrano-unicorn'

role :app, "dev.lists.delaha.us"

set :deploy_to, "/var/www/dev.lists.delaha.us"
set :deploy_via, :remote_cache

set :user, "dev-commonlist-deployer"

set :rvm_ruby_string, :local

set :unicorn_pid, "/var/tmp/#{application}.pid"

before "deploy:setup",         "rvm:install_rvm"
before "deploy:setup",         "rvm:install_ruby"
