require 'dino'

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
    `say 'spinning the wheel'`
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
        `say "#{winner.capitalize} wins, you sweet sweet druggie!"`

        break
      end
      # break if button.down
    end
  end

  def activate!
    button.down do
      spin_the_wheel
    end

    sleep
  end

end

