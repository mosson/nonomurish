set_default(:redis_config) { "/etc/redis/redis.conf" }

namespace :redis do
  desc "Install redis"
  task :install, roles: :web do
    run "#{sudo} yum -y install redis"
  end
  after "deploy:install", "redis:install"

  desc "Setup redis configuration for this application"
  task :setup, roles: :db do
    template "redis.erb", "/tmp/redis.conf"
    run "#{sudo} mv /tmp/redis.conf #{redis_config}"
    restart
  end
  after "deploy:setup", "redis:setup"

  %w[start stop restart].each do |command|
    desc "#{command} redis"
    task command, roles: :db do
      run "#{sudo} /etc/init.d/redis-server #{command}"
    end
  end
end