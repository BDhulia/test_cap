server "54.148.104.94", :app, :web, :db, :primary => true

set :php_env, defer { "staging" }
set :domain, "ruthsstaging.com"
set :domain_alias, "www.ruthsstaging.com"
set :dbname, defer { "ructh" }
set :deploy_to, defer { "/var/www/html/capistranotry/#{user}/sites/#{client}/#{application}" }
