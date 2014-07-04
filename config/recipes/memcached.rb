set_default(:memcached_config) { "/etc/sysconfig/memcached" }

namespace :memcached do
  desc "Install memcached"
  task :install, roles: :web do
    run "#{sudo} yum -y install memcached"
  end
  after "deploy:install", "memcached:install"

  desc "Setup memcached configuration for this application"
  task :setup, roles: :db do
    template "memcached.erb", "/tmp/memcached.conf"
    run "#{sudo} mv /tmp/memcached.conf #{memcached_config}"
    restart
  end
  after "deploy:setup", "memcached:setup"

  %w[start stop restart].each do |command|
    desc "#{command} memcached"
    task command, roles: :db do
      run "#{sudo} /etc/init.d/memcached #{command}"
    end
    after "deploy:#{command}", "memcached:#{command}"
  end
end