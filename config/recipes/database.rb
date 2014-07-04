namespace :db do
  task :setup, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/config"

    put File.read( File.expand_path("../application.yml", File.dirname(__FILE__))), "#{shared_path}/config/application.yml"

    template "database.yml.erb", "#{shared_path}/config/database.yml"
  end

  task :symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:setup",           "db:setup"   unless fetch(:skip_db_setup, false)
after "deploy:finalize_update", "db:symlink"