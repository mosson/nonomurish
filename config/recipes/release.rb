# encoding: utf-8

require 'logan'
require 'pp'
require 'erubis'

begin
  namespace :release do
    task :note, role: :db do
      messages = []

      find_servers_for_task(current_task).each do |current_server|
        messages << %x(git log --oneline `ssh #{user}@#{current_server.host} cat #{current_path}/REVISION`..`git rev-parse HEAD`).split("\n").map{|commit|
          commit.scan(/.+?\s(.+)/).flatten
        }
      end

      messages = messages.flatten.compact.uniq

      basecamp_ID = ENV["BASECAMP_ID"]
      auth_hash = { :username => ENV["BASECAMP_USER"], :password => ENV["BASECAMP_PASSWORD"] }
      user_agent = "LoganUserAgent (#{ENV["BASECAMP_USER"]})"

      logan = Logan::Client.new( basecamp_ID, auth_hash, user_agent )
      project = logan.projects.detect{|project| project.id == basecamp_release_project_id }

      list = Logan::TodoList.new({name: "【CREATIVE SURVEY::#{stage}】 #{DateTime.now.strftime("%Y-%m-%d %H:%M:%S")} リリースノート"})

      target = project.create_todolist(list)

      messages.each do |message|
        m = message << " " << `cool-face`.to_s

        todo = Logan::Todo.new(
            content: m,
            assignee: {
                id: ENV["BASECAMP_USER_ID"],
                type: "Person"
            }
        )

        target.create_todo(todo)
      end
    end
  end

  before "deploy", "release:note"
rescue => e
  puts "RELEASE NOTE FEATURE is unavailable : #{e.message}"
end