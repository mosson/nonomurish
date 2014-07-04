set_default(:unicorn_user) { user }
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
set_default(:unicorn_workers, 6)

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
    template "unicorn_init.erb", "/tmp/unicorn_init"
    template "unicorn_logrotate.erb", "/tmp/unicorn_logrotate_#{application}"

    run "chmod +x /tmp/unicorn_init"
    run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{application}"
    run "#{sudo} /sbin/chkconfig --add unicorn_#{application};#{sudo} /sbin/chkconfig unicorn_#{application} on"
    run "#{sudo} mv /tmp/unicorn_logrotate_#{application} /etc/logrotate.d/unicorn_logrotate_#{application}"

    template "rails_logrotate.erb", "/tmp/#{application}_#{rails_env}_logrotate"
    run "#{sudo} mv /tmp/#{application}_#{rails_env}_logrotate /etc/logrotate.d/#{application}_#{rails_env}_logrotate"
  end
  after "deploy:setup", "unicorn:setup"

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "#{sudo} service unicorn_#{application} #{command}"
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end
end