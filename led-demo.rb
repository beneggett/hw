require 'dino'
require 'httparty'

class HW

  attr_accessor :board

  def initialize
    @board = Dino::Board.new(Dino::TxRx.new)
  end

  def leds
    [blue, red, green, yellow ]
  end

  def blue
    Dino::Components::Led.new(pin: 4, board: board)
  end

  def red
    Dino::Components::Led.new(pin: 5, board: board)
  end

  def green
    Dino::Components::Led.new(pin: 6, board: board)
  end

  def yellow
    Dino::Components::Led.new(pin: 7, board: board)
  end

  def pin_names
    [{name: "yellow", led: yellow.pin},
    {name: "blue", led: blue.pin},
    {name: "green", led: green.pin},
    {name: "red", led: red.pin}]
  end

  def button
    Dino::Components::Button.new(pin: 13, board: board)
  end

  def blink(led, delay = 0.1)
    led.send(:on)
    sleep delay
    led.send(:off)
    sleep delay
  end

  def cycle
    delay = 0.005
    leds.cycle do |led|
      blink(led, delay)
      delay *= 1.1
      puts delay
      break if delay >= 0.29
    end
  end

  def spin_the_wheel
    say('spinning the wheel')
    time = 0
    delay = 0.001
    leds.cycle do |led|
      delay += rand(0.002..0.03)
      time += delay
      blink(led, delay)
      if delay >= 0.33

        puts time
        winner = pin_names.find{|pin| pin[:led] == led.pin}[:name]
        puts "#{winner.capitalize} wins!"
        led.on
        say("#{winner.capitalize} wins, you sweet sweet druggie!")

        break
      end
      # break if button.down
    end
  end

  def who_picks_lunch?
    say('who gets to pick lunch today?')
    time = 0
    delay = 0.001
    leds.cycle do |led|
      delay += rand(0.002..0.03)
      time += delay
      blink(led, delay)
      if delay >= 0.33

        puts time
        winner = pin_names.find{|pin| pin[:led] == led.pin}[:name]
        case winner
        when 'yellow'
          picker = 'cody'
        when 'green'
            picker = 'Andy'
        when 'blue'
          picker = 'ben'
        when 'red'
          picker = 'quintin'
        end
        puts "#{picker.capitalize} wins!"
        led.on
        say("#{picker.capitalize} gets to pick lunch today, and cody pays. you lucky dog!")

        break
      end
      # break if button.down
    end
  end

  def say(message)
    text = message
    key = 'c3d6f27dbd254282becd156f3db13206'
    returned_mp3 = HTTParty.get("http://api.voicerss.org/?key=#{key}&src=#{text}'&hl=en-us&f=48khz_16bit_stereo")
    file = 'speak.mp3'
    File.open(file, 'w') { |file| file.write(returned_mp3.parsed_response) }
    `omxplayer --vol -2000 speak.mp3`
  end

  def activate!
    button.down do
      spin_the_wheel
    end

    sleep
  end

end

