# frozen_string_literal: true

require 'time'
require 'fileutils'

# Loggman class
class Loggman
  def initialize(logfile)
    @logfile = logfile
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

  def delete_old_logs
    max_age_days = 7
    max_age_seconds = max_age_days * 24 * 60 * 60

    if File.exist?(@logfile) && Time.now - File.mtime(@logfile) > max_age_seconds
      FileUtils.rm(@logfile)
    end
  end
end
