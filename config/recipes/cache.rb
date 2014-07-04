# encoding: utf-8

namespace :cache do
  namespace :clear do
    task :all, role: :db do
      run("cd #{current_path}; bundle exec rake cache:clear:all RAILS_ENV=#{rails_env}")
    end

    task :answer, role: :db do
      run("cd #{current_path}; bundle exec rake cache:clear:answer RAILS_ENV=#{rails_env}")
    end
  end
end