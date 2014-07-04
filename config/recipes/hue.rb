# encoding: utf-8

require "hue_control"

namespace :hue do
  task :start do
    lamp_id = ( stage.to_s == "production" ? 4 : 3 )

    h = HueControl.new([lamp_id])
    h.update_attributes(on: true, hue: 0, brightness: 255, saturation: 255)
  end

  task :complete do
    lamp_id = ( stage.to_s == "production" ? 4 : 3 )

    h = HueControl.new([lamp_id])
    h.update_attributes(on: true, hue: 227, brightness: 255, saturation: 255)

    threads = []
    10.times do |i|
      threads << Thread.new do
        sleep( (i+1)*2 )
        h.toggle(i%2 == 0)
      end
    end

    threads << Thread.new do
      sleep( (11+1)*2 )
      h.turn_off
    end

    threads.each{|t| t.join }
  end
end

before "deploy", "hue:start"
after "deploy", "hue:complete"

before "deploy:migrate", "hue:start"
after "deploy:migrate", "hue:complete"

before "unicorn:stop", "hue:start"
after "unicorn:start", "hue:complete"

before "deploy:site", "hue:start"
after "deploy:site", "hue:complete"

