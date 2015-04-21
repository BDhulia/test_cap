require 'capistrano/ext/multistage'
set :stages, %w(staging production)
set :default_stage, 'staging'




set :client, 'ruthschris'
set :application, 'ruthschris'
set :user, 'deployer'
set :deploy_via, :remote_cache
set :use_sudo, false

set :deploy_to, "/var/www/html/capistranotry/#{user}/sites/#{client}/#{application}"
set :dbname, "ructh"

set :scm, 'git'
set :repository, "git@github.com:BDhulia/RuthsChris.git"

set :branch, 'staging'
set :scm_passphrase, "rsc12345"
set :user, "bdhulia@reliablegroup.com"

set :scm_verbose, true

set :copy_exclude, %w(.git .gitignore README.md)

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy', 'deploy:cleanup'
