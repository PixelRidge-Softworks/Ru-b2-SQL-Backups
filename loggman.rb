# frozen_string_literal: true

require 'time'
require 'fileutils'

# Loggman class
class Loggman
  LOG_PREFIX = 'log'
  LOG_DURATION = 7 * 24 * 60 * 60 # 1 week
  MAX_LOG_AGE = 60 * 24 * 60 * 60 # 2 months

  def initialize(log_dir = nil)
    @log_dir = log_dir || default_log_dir
    @logfile = generate_logfile
  end

  def log(message, level = :info)
    delete_old_logs
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    File.open(@logfile, 'a') do |file|
      file.puts "[#{timestamp}] [#{level.to_s.upcase}] #{message}"
    end
  end

  def info(message)
    log(message, :info)
  end

  def warn(message)
    log(message, :warn)
  end

  def error(message)
    log(message, :error)
  end

  def debug(message)
    log(message, :debug)
  end

  private

  def default_log_dir
    backup_dir = MysqlDatabaseConfig.new(nil).backup_dir
    File.join(backup_dir, 'logs')
  end

  def generate_logfile
    start_time = Time.now
    log_start_day = start_time.strftime('%Y-%m-%d')
    end_time = start_time + LOG_DURATION
    log_end_day = end_time.strftime('%Y-%m-%d')
    log_filename = "#{LOG_PREFIX}-#{log_start_day}-#{log_end_day}.log"
    log_path = File.join(@log_dir, log_filename)
    FileUtils.mkdir_p(@log_dir)
    log_path
  end

  def delete_old_logs
    Dir.glob(File.join(@log_dir, "#{LOG_PREFIX}-*.log")).each do |logfile|
      FileUtils.rm(logfile) if Time.now - File.mtime(logfile) > MAX_LOG_AGE
    end
  end
end
