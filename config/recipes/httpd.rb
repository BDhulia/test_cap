set_default(:httpd_auth_basic_username) { Capistrano::CLI.ui.ask "Enter #{php_env} auth basic username: " }
set_default(:httpd_auth_basic_password) { Capistrano::CLI.password_prompt "Enter #{php_env} auth basic password: " }
set_default :vhost_dir, lambda { '/etc/httpd/conf/vhosts' }

namespace :httpd do
  desc "Add HTTP Basic Authentication"
  task :auth_basic, roles: :web do
    htpasswd = "#{httpd_auth_basic_username}:#{%Q{#{httpd_auth_basic_password}}.crypt(%Q{#{application}})}"
    commands = []
    commands << "mkdir -p #{shared_path}/htpasswd"
    commands << "echo '#{htpasswd}' >> #{shared_path}/htpasswd/.htpasswd"

    run commands.join(" && ")
  end

  desc "Setup httpd configuration for this application"
  task :setup, roles: :web do
    auth_basic if php_env == "uat"
    run "#{sudo} mkdir -p #{deploy_to}"
    template "httpd.erb", "/tmp/#{domain}.conf"
    if php_env == "production" || php_env == "web1" || php_env == "webdb1"
      vhost_dir = '/etc/httpd/conf/vhosts' 
    else 
      vhost_dir = '/etc/httpd/sites-available'
    end
    run "#{sudo} mv /tmp/#{domain}.conf #{vhost_dir}/#{domain}.conf"
    run "#{sudo} /usr/sbin/a2ensite #{domain}.conf" if php_env != "production"
    restart
  end
  after "deploy:setup", "httpd:setup"
  
  %w[start stop restart].each do |command|
    desc "#{command.capitalize} httpd"
    task command, roles: :web do
      run "#{sudo} /sbin/service httpd #{command}"
    end
  end
end
