require 'rubygems'
require 'summer'
load '../led-demo.rb'
load '../twilio.rb'
class LightBot < Summer::Connection

  def channel_message(sender, channel, message)

    if message =~ /spin/
      puts "Spinning the wheel"
      HW.new().spin_the_wheel
    elsif message =~ /DRUGbot: say/
      ` say "#{message.gsub('DRUGbot: say', '')}"`
    elsif message =~ /DRUGbot: send /
      Messenger.new().message(message.gsub('DRUGbot: send', ''))
    elsif message =~ /DRUGbot: sendpic /
      Messenger.new().picture_message("just for you, from #{sender}", message.gsub('DRUGbot: sendpic ', '') )
    end

    # direct_at(sender[:nick], message)
  end

  def direct_at(reply_to, message, who=nil)
    message = who + ": #{message}" if who
    privmsg(message, reply_to)
  end

end

LightBot.new('irc.freenode.net')
