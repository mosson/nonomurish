# encoding: utf-8

require 'error_entry'
require 'log_report'

# ログを素早く読み取る
namespace :log do
  task :tail do
    run "cd #{current_path}; tail -n 100 log/#{rails_env}.log"
  end

  task :revision, role: :db do
    find_servers_for_task(current_task).each do |current_server|
      system "echo `ssh #{user}@#{current_server.host} cat #{current_path}/REVISION`"
    end
  end

  task :diff, role: :db do
    find_servers_for_task(current_task).each do |current_server|
      system "git diff `ssh #{user}@#{current_server.host} cat #{current_path}/REVISION`"
    end
  end

  task :message, role: :db do
    find_servers_for_task(current_task).each do |current_server|
      system "git log --oneline `ssh #{user}@#{current_server.host} cat #{current_path}/REVISION`..`git rev-parse HEAD`"
    end
  end

  task :fetch do
    result = "".tap do |result|
      find_servers_for_task(current_task).each do |server|
        run "cd #{current_path}; cat log/#{stage}.log", :hosts => server.host do |channel, stream, data|
          result << data
        end
      end
    end

    File.write("/tmp/#{stage}.log", result)
  end

  task :fetch2 do
    find_servers_for_task(current_task).each_with_index do |server, index|
      download(File.join(current_path, "log", "#{stage}.log-20140509.gz"), "/tmp/#{stage}_#{index}.log-20140509.gz")
    end
  end

  task :report do
    result = "".tap do |result|
      find_servers_for_task(current_task).each do |server|
        run "cd #{current_path}; cat log/#{stage}.log", :hosts => server.host do |channel, stream, data|
          result << data
        end
      end
    end

    log_report = LogReport.new(result)
    log_report.retrieve
    log_report.write_ips
    log_report.write
  end

  task :report40x do
    result = "".tap do |result|
      find_servers_for_task(current_task).each do |server|
        run "cd #{current_path}; cat log/#{stage}.log", :hosts => server.host do |channel, stream, data|
          result << data
        end
      end
    end

    log_report = LogReport.new(result)
    log_report.retrieve_40x
    log_report.write_40x
  end

  task :report50x do
    result = "".tap do |result|
      find_servers_for_task(current_task).each do |server|
        run "cd #{current_path}; cat log/#{stage}.log", :hosts => server.host do |channel, stream, data|
          result << data
        end
      end
    end

    log_report = LogReport.new(result)
    log_report.retrieve_50x
    log_report.write_50x
  end
end