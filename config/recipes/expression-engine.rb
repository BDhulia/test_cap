set_default(:ee_config_db_host) { Capistrano::CLI.ui.ask "Enter #{php_env} database host (blank for localhost): " }
set_default(:ee_config_db_username) { Capistrano::CLI.ui.ask "Enter #{php_env} database username: " }
set_default(:ee_config_db_password) { Capistrano::CLI.password_prompt "Enter #{php_env} database password: " }

dirs  = {
          'cache'                         =>  '777',
          'img'                           =>  '777',
          'images/avatars'                =>  '777',
          'images/captchas'               =>  '777',
          'images/member_photos'          =>  '777',
          'images/pm_attachments'         =>  '777',
          'images/signature_attachments'  =>  '777',
          'images/smileys'                =>  '777',
          'pdfs'                          =>  '755'
        }

namespace :expression_engine do
  desc "Setup Expression Engine for this application"
  task :setup, :roles => :web do
    dirs.each do |name, permission|
      run "mkdir -p #{shared_path}/#{name}"
      run "chmod -Rf #{permission} #{shared_path}/#{name}"
    end
    run "mkdir -p #{shared_path}/sys/expressionengine/cache"
    run "chmod -Rf 755 #{shared_path}/sys/expressionengine/cache"
    run "mkdir -p #{shared_path}/public/includes"
    run "mkdir -p #{shared_path}/sys/expressionengine/config"
    template "pub_inc_config.erb", "#{shared_path}/public/includes/config.php"
    template "sys-ee-config.erb", "#{shared_path}/sys/expressionengine/config/config.php"
    template "sys-ee-database.erb", "#{shared_path}/sys/expressionengine/config/database.php"
  end
  after "deploy:setup", "expression_engine:setup"

  desc "Symlink Expression Engine directories"
  task :symlink, :roles => :web do
    dirs.each do |name, permission|
      run "rm -Rf #{release_path}/public/#{name}"
      run "ln -nfs #{shared_path}/#{name} #{release_path}/public/#{name}"
    end
    run "rm -Rf #{release_path}/sys/expressionengine/cache"
    run "ln -nfs #{shared_path}/sys/expressionengine/cache #{release_path}/sys/expressionengine/cache"
    run "ln -nfs #{shared_path}/public/includes/config.php #{release_path}/public/includes/config.php"
    run "ln -nfs #{shared_path}/sys/expressionengine/config/config.php #{release_path}/sys/expressionengine/config/config.php"
    run "ln -nfs #{shared_path}/sys/expressionengine/config/database.php #{release_path}/sys/expressionengine/config/database.php"
    run "rm -Rf #{shared_path}/img" if php_env == 'production'
    run "ln -nfs /var/ruthschris/img #{release_path}/public/img" if php_env == 'production'
  end
  after "deploy:finalize_update", "expression_engine:symlink"
end
