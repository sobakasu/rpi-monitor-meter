require 'pi_piper'

module MonitorMeter

  class TemperatureSensor

    attr_accessor :temperature, :humidity

    def initialize(config = nil)
      self.config = config unless config.nil?
    end

    def config=(config)
      @pin = config['temp_gpio_pin']
    end

    def take_measurement
      return unless @pin

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

  end

end
