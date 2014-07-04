set_default(:god_user)  { user }
set_default(:god_path)  { "/usr/local/bin/bootup_god" }
set_default(:god_pid)   { "#{current_path}/tmp/pids/god.pid" }
set_default(:god_config){ "#{shared_path}/config/god.rb" }
set_default(:god_log)   { "#{shared_path}/log/god.log" }
set_default(:rake_path) { "/usr/local/bin/bootup_rake" }

namespace :god do
  desc "Setup god initializer and app configuration"
  task :setup, roles: :app do

    # rvm bootable rake generate => will be generate "~/.rvm/bin/bootup_rake"
    run "rvm wrapper `rvm alias show default` bootup god"
    run "#{sudo} ln -f -s ~/.rvm/bin/bootup_god #{god_path}"

    run "rvm wrapper `rvm alias show default` bootup rake"
    run "#{sudo} ln -f -s ~/.rvm/bin/bootup_rake #{rake_path}"

    run "mkdir -p #{shared_path}/config"
    template "god.rb.erb", god_config
    template "god_init.erb", "/tmp/god"
    run "chmod +x /tmp/god"
    run "#{sudo} mv /tmp/god /etc/init.d/god"
    run "#{sudo} /sbin/chkconfig --add god;#{sudo} /sbin/chkconfig god on"
  end
  after "deploy:setup", "god:setup"

  %w[start stop restart].each do |command|
    desc "#{command} god"
    task command, roles: :app do
      run "#{sudo} service god #{command}"
    end
    after "deploy:#{command}", "god:#{command}"
  end
end