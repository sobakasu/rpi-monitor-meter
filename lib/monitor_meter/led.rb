require 'pi_piper'

module MonitorMeter

  class LED

    DEFAULT_MAX_THRESHOLD = 200

    attr_accessor :threshold_min, :threshold_max
    attr_reader :last_value

    def initialize
      @threshold_max = DEFAULT_MAX_THRESHOLD
      @last_value = on?
    end

    def take_measurement
      measurement = 0

      # discharge capacitor
      pin = PiPiper::Pin.new(:pin => 17, direction: :out)
      pin.off
      sleep 0.1
      
      # measure time to charge capacitor
      pin = PiPiper::Pin.new(:pin => 17, direction: :in)
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
