require 'rpi_gpio'

module MonitorMeter

  class LED

    DEFAULT_MAX_THRESHOLD = 200
    DEFAULT_PIN = 17

    attr_accessor :threshold_min, :threshold_max, :pin
    attr_reader :last_value

    def initialize(config = nil)
      ::RPi::GPIO.set_numbering :bcm
      @threshold_max = DEFAULT_MAX_THRESHOLD
      @pin = DEFAULT_PIN
      self.config = config unless config.nil?

      @last_value = on?
    end

    def config=(config)
      @threshold_min = config['led_threshold_min']
      @threshold_max = config['led_threshold_max']
      @pin = config['led_gpio_pin']
    end

    def take_measurement
      measurement = 0

      # discharge capacitor
      ::RPi::GPIO.setup(@pin, as: :output, initialize: :low)
      ::RPi::GPIO.set_low(@pin)
      sleep 0.1
      
      # measure time to charge capacitor
      ::RPi::GPIO.setup(@pin, as: :input, pull: :down)
      while(::RPi::GPIO.low?(@pin)) do
        sleep 0.005
        measurement += 1
        break if measurement >= (@threshold_max || DEFAULT_MAX_THRESHOLD)
      end
      
      #puts "measurement: #{measurement}"
      measurement
    end
    
    def on?
      take_measurement <= (@threshold_min || 0)
    end

    def changed?
      value = on?
      if value != @last_value
        @last_value = value
        true
      else
        false
      end
    end    

  end

end
