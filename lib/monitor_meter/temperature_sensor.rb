require 'pi_piper'

module MonitorMeter

  class TemperatureSensor

    attr_accessor :temperature, :humidity

    def initialize(config = nil)
      self.config = config unless config.nil?
    end

    def config=(config)
      @device_id = config['temp_gpio_device_id']
    end

    def device_path
      "/sys/bus/w1/devices/#{@device_id}/w1_slave"
    end

    def take_measurement
      return unless @device_id

      data = File.readlines(device_path)
      return nil unless data && data.length >= 2
      return nil unless data[0].strip.end_with?("YES") # crc ok
      return data[1].split(/=/).last.to_i / 1000.0
    end

  end

end
