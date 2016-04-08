# require 'rubygems'
require 'summer'
require 'httparty'
require 'hashie'
require 'ffaker'
require 'pstore'
require 'audite'

load '../led-demo.rb'
# load '../twilio.rb'
class Bot < Summer::Connection
  URI_REGEX = %r"((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)"
  JIRA = PStore.new("jira.pstore")

  def channel_message(sender, channel, message)
    # unless sender[:nick] == 'quintinadam'
    #   response = Hashie::Mash.new(HTTParty.get("https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{ENV['TRANSLATION_Key']}&lang=en-es&text=#{message}"))
    #   direct_at(channel, response.text.join())
    #   `say "#{response.text.join()}"`
    # end

    if sender[:nick] =~ /SLACK/ && message =~ /github.com/
      say message

    end

    if sender[:nick] =~ /SLACK/ && message =~ /Build/
      what, how = message.split('access-development').last.split('by ')
      project, branch = what.gsub('@', ', ').gsub('-', ' ' ).gsub('/', '').split(',')
      status = how.split(' in ').first.split().last
      who = how.split(' in ').first.gsub(status, '')
      first_name = who.split().first
      if status =~ /failed/
        gif =  Hashie::Mash.new(HTTParty.get("http://api.giphy.com/v1/gifs/translate?s=fail&api_key=dc6zaTOxFJmzC") )

        message_reply = "Oh, no! #{who} broke the build on #{project}, #{branch} branch. Hey, #{first_name}, #{get_insult}"
      elsif message =~ /passed/
        gif =  Hashie::Mash.new(HTTParty.get("http://api.giphy.com/v1/gifs/translate?s=success&api_key=dc6zaTOxFJmzC") )

        message_reply = "Great Job, #{who}! Your tests are passing on #{project}, #{branch} branch! You know, #{first_name}, #{get_motivation(first_name)}"
      elsif message =~ /errored/
        gif =  Hashie::Mash.new(HTTParty.get("http://api.giphy.com/v1/gifs/translate?s=error&api_key=dc6zaTOxFJmzC") )

        message_reply = "Hey #{who}, your build errored out on #{project}, #{branch} branch. Take a look! #{gif.data.images.original.url}"
      else
        gif =  Hashie::Mash.new(HTTParty.get("http://api.giphy.com/v1/gifs/translate?s=confused&api_key=dc6zaTOxFJmzC") )
        message_reply = "Hmm.... "
      end
      direct_at(channel, "#{message_reply} #{gif.data.images.original.url if gif }")
      say message_reply
    end



    if message =~ /spin/
      puts "Spinning the wheel"
      gif =  Hashie::Mash.new(HTTParty.get("http://api.giphy.com/v1/gifs/translate?s=spin+the+wheel&api_key=dc6zaTOxFJmzC") )
      direct_at(channel, "Spinning the wheel. #{gif.data.images.original.url}")

      HW.new().spin_the_wheel
    end

    if message =~ /lunch/
      puts "Lunch Raffle!"
      gif =  Hashie::Mash.new(HTTParty.get("http://api.giphy.com/v1/gifs/translate?s=lunch&api_key=dc6zaTOxFJmzC") )
      direct_at(channel, "Raffle! #{gif.data.images.original.url}")

      HW.new().who_picks_lunch?
    end

    if message =~ /#{config[:nick]}: send /
      Messenger.new().message(message.gsub("@", "").gsub("#{config[:nick]}: send", ''))
    end
    if message =~ /#{config[:nick]}: sendpic /
      Messenger.new().picture_message("just for you, from #{sender}", message.gsub("#{config[:nick]}: sendpic ", '') )
    end

    if message =~ /#{config[:nick]}: insult /
      who = message.gsub(/#{config[:nick]}: insult /, '')
      msg =   "#{who}: #{get_insult}"
      direct_at(channel, msg)
      say msg
    end

    if message =~ /be nice/
      who = sender[:nick]
      msg =   "#{who}: #{get_insult}"
      direct_at(channel, msg)
      say msg
    end

    if message =~ /pun/
      msg =   get_pun
      direct_at(channel, msg)
      say msg
    end

    jira_regexp = /\b(A[MWL][PD]-\d+)\b/
    if message =~ jira_regexp && !message.include?('issues.accessdevelopment.com/browse')
      JIRA.transaction do
        JIRA[:links] ||= Hash.new
      end
      a = message.scan jira_regexp
      who = sender[:nick]
      issues = a.flatten.map do |issue|
        JIRA.transaction do
          if JIRA[:links][issue] && (JIRA[:links][issue] >= (DateTime.now - Rational(120, 86400)))
            nil
          else
            JIRA[:links][issue] =  DateTime.now
            "@#{who} is making me work too hard for this: https://issues.accessdevelopment.com/browse/#{issue}"
          end
        end
      end
      issues.compact.uniq.each {|msg| direct_at(channel, msg) }
    end

    if message =~ /#{config[:nick]}: motivate /
      who = message.gsub(/#{config[:nick]}: motivate /, '')
      msg =   "#{who}, #{get_motivation(who)}"
      direct_at(channel, msg)
      say msg
    end

    if message =~ /#{config[:nick]}: inspire /
      who = message.gsub(/#{config[:nick]}: inspire /, '')
      msg =   "#{who}: #{get_inspiration}"
      direct_at(channel, msg)
      say msg
    end


    if message =~ /#{config[:nick]}: say /
      msg = message.gsub(/#{config[:nick]}: say /, '')
      say msg
    end

    if message =~ /cody/
      say "cody stop being a slacker. #{get_insult}"
    end
  end

  def direct_at(reply_to, message, who=nil)
    message = "#{who}: #{message}" if who
    privmsg(message, reply_to)
  end

  def clean_message_for_speech(message)
    message.split(URI_REGEX).collect do |s|
      unless s =~ URI_REGEX
        s
      end
    end.join.gsub(',', '').gsub('/', ' ').gsub('@', '').gsub('"', '').gsub("'", '').gsub('#', '').gsub('(', '').gsub(')', '').gsub('!', '').gsub('’', '').gsub('‘', '').gsub('’', '').gsub('&quot;', "")
  end

  def say(message)
    text = clean_message_for_speech(message)
    key = 'c3d6f27dbd254282becd156f3db13206'
    returned_mp3 = HTTParty.get("http://api.voicerss.org/?key=#{key}&src=#{text}'&hl=en-gb&f=48khz_16bit_stereo")

    file = 'speak.mp3'
    File.open(file, 'w') { |file| file.write(returned_mp3.parsed_response) }

    player = Audite.new
    player.load('speak.mp3')
    player.start_stream
  end

  def get_insult
    # "Yurr dun reel stoopid. (my insult api is broken)"
    Hashie::Mash.new(HTTParty.get("http://quandyfactory.com/insult/json") ).insult
  end

  def get_motivation(name)

    # "Keep doing good. (my motivation api is broken)"
    Hashie::Mash.new(HTTParty.get("http://api.icndb.com/jokes/random?firstName=#{name.gsub('@', '')}&lastName=") ).value.joke.gsub('&quot;', "\'")
  end

  def get_inspiration
    # "You dun good. (my inspiration api is broken)"
    HTTParty.get("http://ron-swanson-quotes.herokuapp.com/v2/quotes").first
  end

  def get_pun
    Hashie::Mash.new(HTTParty.get("http://www.kimonolabs.com/api/2oiziu8k?apikey=a1843d6ac7111afa6ee3014e6834de0c")).results.puns.sample.pun
  end

end

BEGIN { File.write("#{ $0 }.pid", $$) }
END { File.delete("#{ $0 }.pid") }
$stdout.reopen("bot.log", "w")
$stderr.reopen("error.log", "w")

Bot.new(ENV['IRC_SERVER'])

