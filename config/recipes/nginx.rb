set_default(:nginx_user)        { "nginx" }
set_default(:nginx_pid)         { "/var/run/nginx.pid" }
set_default(:nginx_access_log)  { "/var/log/nginx/access.log" }
set_default(:nginx_error_log)   { "/var/log/nginx/error.log" }
set_default(:nginx_workers, 1)
set_default(:nginx_basic_passwd) {"/var/www/.htpasswd"}


namespace :nginx do
  desc "Install nginx"
  task :install, roles: :web do
    run "#{sudo} yum -y install nginx"
  end
  after "deploy:install", "nginx:install"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template "nginx.conf.erb", "/tmp/nginx.conf"
    run "#{sudo} mv /tmp/nginx.conf /etc/nginx/nginx.conf"

    template "nginx_unicorn.erb", "/tmp/nginx_conf"
    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/conf.d/#{application}.conf"
    run "#{sudo} rm -f /etc/nginx/conf.d/default"

    template "nginx_logrotate.erb", "/tmp/nginx_logrotate"
    run "#{sudo} mv /tmp/nginx_logrotate /etc/logrotate.d/nginx_logrotate"

    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end