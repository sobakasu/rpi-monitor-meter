require 'pi_piper'

module MonitorMeter

  class LED

    DEFAULT_MAX_THRESHOLD = 200
    DEFAULT_PIN = 17

    attr_accessor :threshold_min, :threshold_max, :pin
    attr_reader :last_value

    def initialize(config = nil)
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
      pin = PiPiper::Pin.new(:pin => @pin, direction: :out)
      pin.off
      sleep 0.1
      
      # measure time to charge capacitor
      pin = PiPiper::Pin.new(:pin => @pin, direction: :in)
      pin.read
      while(pin.off?) do
        #puts "value: #{pin.value}, low: #{pin.off?}"
        pin.read
        measurement += 1
        break if measurement >= (@threshold_max || DEFAULT_MAX_THRESHOLD)
      end
      
      #puts "measurement: #{measurement}"
      measurement
    end
    
    def on?
      begin
        take_measurement <= (@threshold_min || 0)
      rescue Exception => e
        puts "error reading pin: #{e.message}"
        @last_value
      end
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
