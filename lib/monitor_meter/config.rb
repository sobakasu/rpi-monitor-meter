require 'yaml'

module MonitorMeter

  class Config
    
    CONFIG_FILENAME = "monitor_meter.conf"
    
    attr_reader :status_interval
    
    def initialize
      @data = read_config

      # convert status interval to seconds
      @status_interval = (@data['status_interval'] || 0).to_i * 60
      unless @status_interval % (5 * 60) == 0 && @status_interval > 0
        # default status interval 5 minutes
        @status_interval = 5 * 60
      end
    end
    
    def [](key)
      @data[key.to_s]
    end
    
    private
    
    def read_config
      path = File.join(File.dirname(__FILE__), "..", "..", CONFIG_FILENAME)
      unless File.exist?(path)
        puts "error: " + CONFIG_FILENAME + " not found."
        exit(1)
      end
      
      config = YAML.load_file(path)
      p config
      config
    end
    
  end

end



