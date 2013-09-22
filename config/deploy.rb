require 'capistrano/ext/multistage'

# This is a workaround. Without this option, capistrano attempts to touch all
# of the files under public/images, public/stylesheets, and public/javascripts
# but these parent folders do not exist.
set :normalize_asset_timestamps, false

set :application, "commonlist"
set :repository,  "https://github.com/CSHsf/CommonList.git"

set :scm, :git
set :use_sudo, false

set :ssh_options, { :forward_agent => true }
