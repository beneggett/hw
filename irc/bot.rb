# require 'rubygems'
require 'summer'
require 'httparty'
require 'hashie'
require 'ffaker'

load '../led-demo.rb'
# load '../twilio.rb'
class Bot < Summer::Connection
  URI_REGEX = %r"((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)"

  def channel_message(sender, channel, message)
    # unless sender[:nick] == 'quintinadam'
    #   response = Hashie::Mash.new(HTTParty.get("https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{ENV['TRANSLATION_Key']}&lang=en-es&text=#{message}"))
    #   direct_at(channel, response.text.join())
    #   `say "#{response.text.join()}"`
    # end

    if sender[:nick] =~ /SLACK/ && message =~ /github.com/

      text = message.split(URI_REGEX).collect do |s|
        unless s =~ URI_REGEX
          s
        end
      end.join
      ` say #{text} `

    end

    if sender[:nick] =~ /SLACK/ && message =~ /Build/
      what, how = message.split('access-development').last.split('by ')
      project, branch = what.gsub('@', ', ').gsub('-', ' ' ).gsub('/', '').split(',')
      status = how.split(' in ').first.split().last
      who = how.split(' in ').first.gsub(status, '')
      first_name = who.split().first
      if status =~ /failed/
        response = Hashie::Mash.new(HTTParty.get("http://pleaseinsult.me/api?severity=random") )
        message_reply = "Oh, no! #{who} broke the build on #{project}, #{branch} branch. Hey, #{first_name}, #{response['insult']}"
      elsif message =~ /passed/
        response = Hashie::Mash.new(HTTParty.get("http://pleasemotivate.me/api") )
        message_reply = "Great Job, #{who}! Your tests are passing on #{project}, #{branch} branch! You know, #{first_name}, #{response['motivation']} "
      elsif message =~ /errored/
        message_reply = "Hey #{who}, your build errored out on #{project}, #{branch} branch. Take a look!"
      else
        message_reply = 'Hmm....'
      end
      direct_at(channel, message_reply)
      ` say "#{message_reply}"" `
    end

    if message =~ /cody/
      ` say cody, stop being a slacker. #{sender[:nick]} says #{message.gsub('cody', '')} `
    end
    if message =~ /spin/
      puts "Spinning the wheel"
      HW.new().spin_the_wheel
    end

    if message =~ /lunch/
      puts "Lunch Raffle!"
      HW.new().who_picks_lunch?
    end

    if message =~ /#{ENV['NICK']}: say /
      ` say "#{message.gsub('@', '').gsub("#{ENV['NICK']}: say", '')}"`
    end
    if message =~ /#{ENV['NICK']}: send /
      Messenger.new().message(message.gsub("@", "").gsub("#{ENV['NICK']}: send", ''))
    end
    if message =~ /#{ENV['NICK']}: sendpic /
      Messenger.new().picture_message("just for you, from #{sender}", message.gsub("#{ENV['NICK']}: sendpic ", '') )
    end

    # direct_at(sender[:nick], message)
  end

  def direct_at(reply_to, message, who=nil)
    message = "#{who}: #{message}" if who
    privmsg(message, reply_to)
  end

end
Bot.new(ENV['IRC_SERVER'])
# Bot.new('irc.freenode.net')
