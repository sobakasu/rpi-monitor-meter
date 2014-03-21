require 'sqlite3'

module MonitorMeter
  class DB

    DB_PATH = File.join(File.dirname(__FILE__), "..", "..", "monitor_meter.db")

    def initialize(config)
      @db = SQLite3::Database.new DB_PATH
      @config = config

      create_table
    end

    def add_measurement(value, temperature, date)
      @db.execute("INSERT INTO measurements " + 
                  "(value, temperature, created_at) VALUES (?,?,?)",
                  [value, temperature, date])
      puts "measurement: #{value}, temp: #{temperature}, date: #{date}"
    end

    def last_record_time
      rows = @db.execute("SELECT created_at FROM measurements ORDER BY created_at DESC LIMIT 1")
      rows[0]
    end

    # return measurements to be uploaded to pvoutput
    # find measurements where
    #  - uploaded_pvoutput is false
    #  - created_at is in the past
    def measurements_for_upload
      list = []
      timestamp = Time.now.to_i 
      max_age = timestamp - 14 * 60 * 60 * 24  # 14 days old

      sql = "SELECT id, value, temperature, created_at, uploaded_pvoutput " +
        "FROM measurements " +
        "WHERE uploaded_pvoutput IS NOT 1 AND created_at < ? " +
        "AND created_at > ?"

      if @config['skip_zero_upload']
        sql += " AND value > 0"
      end

      @db.execute(sql, timestamp, max_age) do |row|
        @measurement = Measurement.new
        @measurement.id = row[0]
        @measurement.value = row[1]
        @measurement.temperature = row[2]
        @measurement.created_at = row[3]
        @measurement.uploaded_pvoutput = row[4]

        list << @measurement
      end
      list
    end

    def mark_uploaded(measurements)
      return if measurements.length == 0

      placeholders = (["?"] * measurements.length).join(",")
      @db.execute("UPDATE measurements SET uploaded_pvoutput = 1 " + 
                  "WHERE id IN (#{placeholders})",
                  measurements.collect { |i| i.id })
    end

    private

    def create_table
      @db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value INTEGER,
        temperature REAL,
        created_at DATE,
        uploaded_pvoutput BOOLEAN
    );
SQL
    end

  end

  class Measurement
    attr_accessor :id, :value, :temperature, :created_at, :uploaded_pvoutput

    def watt_hours
      value
    end

  end

end
