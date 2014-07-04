namespace :mysqld do
  desc "Install mysqld"
  task :install, roles: :web do
    run "#{sudo} yum -y install mysql-server"
  end
  after "deploy:install", "mysqld:install"

  desc "Setup mysqld configuration for this application"
  task :setup, roles: :db do
    template "mysqld.erb", "/tmp/my.cnf"
    run "#{sudo} mv /tmp/my.cnf /etc/my.cnf"
    run "#{sudo} /sbin/chkconfig --add mysqld;#{sudo} /sbin/chkconfig mysqld on"
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} mysqld"
    task command, roles: :db do
      run "#{sudo} service mysqld #{command}"
    end
  end
end