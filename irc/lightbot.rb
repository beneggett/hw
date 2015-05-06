require 'rubygems'
require 'summer'
require 'httparty'
require 'hashie'
load '../led-demo.rb'
# load '../twilio.rb'
class LightBot < Summer::Connection

  def channel_message(sender, channel, message)
    unless sender[:nick] == 'quintinadam'
      response = Hashie::Mash.new(HTTParty.get("https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{ENV['TRANSLATION_Key']}&lang=en-es&text=#{message}"))
      direct_at(channel, response.text.join())
      `say "#{response.text.join()}"`
    end
    if sender[:nick] =~ /SLACK/ && message =~ /github.com/
      URI_REGEX = %r"((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)"

      text = message.split(URI_REGEX).collect do |s|
        unless s =~ URI_REGEX
          s
        end
      end.join
      ` say #{text} `

    end

    if message =~ /cody/
      ` say cody, stop being a slacker. #{sender[:nick]} says #{message.gsub('cody', '')} `
    end
    # if message =~ /spin/
    #   puts "Spinning the wheel"
    #   HW.new().spin_the_wheel
    # end

    if message =~ /lunch/
      puts "Lunch Raffle!"
      HW.new().who_picks_lunch?
    end
    # elsif message =~ /DRUGbot: say/
    #   ` say "#{message.gsub('DRUGbot: say', '')}"`
    # elsif message =~ /DRUGbot: send /
    #   Messenger.new().message(message.gsub('DRUGbot: send', ''))
    # elsif message =~ /DRUGbot: sendpic /
    #   Messenger.new().picture_message("just for you, from #{sender}", message.gsub('DRUGbot: sendpic ', '') )
    # end

    # direct_at(sender[:nick], message)
  end

  def direct_at(reply_to, message, who=nil)
    message = who + ": #{message}" if who
    privmsg(message, reply_to)
  end

end

LightBot.new(ENV['IRC_SERVER'])
# LightBot.new('irc.freenode.net')
