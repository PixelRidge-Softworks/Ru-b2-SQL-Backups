# frozen_string_literal: true

require 'json'
require_relative 'loggman'

# class for handling the config
class MysqlDatabaseConfig
  def initialize(config_file, logger)
    @config_file = config_file
    @logger = logger
  end

  def generate # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @logger.info("Generating MySQL database configuration file: #{@config_file}.")

    if File.exist?(@config_file)
      @logger.info('Config file already exists, skipping generation.')
    else
      begin
        mysql_host = prompt('MySQL Host')
        mysql_username = prompt('MySQL Username')
        mysql_password = prompt('MySQL Password')

        backup_dir = prompt('Backup Directory', default: '.')

        local_retention_days = prompt('Local backup retention in days (1 day minimum)', default: '1').to_i

        @config = {
          'mysql' => {
            'host' => mysql_host,
            'username' => mysql_username,
            'password' => mysql_password
          },
          'backup_dir' => backup_dir,
          'local_retention_days' => local_retention_days
        }
        b2_enabled = prompt_bool('Enable Backblaze B2?', default: false)
        @config['b2_enabled'] = b2_enabled
        if b2_enabled
          @b2_key_id = prompt('B2 Key ID')
          @b2_application_key = prompt('B2 Application Key')
          @b2_bucket_name = prompt('B2 Bucket Name')
          b2_retention_days = prompt('B2 backup retention in days (1 day minimum)', default: '1').to_i
          @config['b2'] = {
            'key_id' => @b2_key_id,
            'application_key' => @b2_application_key,
            'bucket_name' => @b2_bucket_name,
            'retention_days' => b2_retention_days
          }
        end

        File.write(@config_file, JSON.pretty_generate(@config))
        @logger.info("Config file generated: #{@config_file}")
      rescue StandardError => e
        @logger.error("An error occurred while generating MySQL database configuration file: #{e.message}")
        @logger.debug("Backtrace: #{e.backtrace}")
      end

      # ask the user if they want to setup a cron job for the program
      cron_job = prompt_bool('Do you want to setup a cron job for this program?', default: false)
      if cron_job
        # how often the program should run
        cron_interval = prompt('How often do you want the program to run? (in minutes, e.g. "60" for every hour)',
                               default: '60').to_i
        # write the cron job to crontab
        `echo "*/#{cron_interval} * * * * /usr/bin/PixelRidge-Softworks/Ruby/Ru-b2-SQL-Backups/rub2" >>
        /etc/crontab`
        @logger.info("Cron job added to /etc/crontab to run every #{cron_interval} minutes.")
      end
    end
  end

  private

  def prompt(message, default: nil)
    print message
    print " [#{default}]" if default
    print ': '
    value = gets.chomp
    value.empty? ? default : value
  end

  def prompt_bool(message, default: false)
    prompt("#{message} (y/n)", default:) =~ /y|yes/i
  end
end

config_file = 'config.json'
logger = Loggman.new

begin
  logger.info('Starting script.')
  config_generator = MysqlDatabaseConfig.new(config_file, logger)
  config_generator.generate
  logger.info('MySQL database configuration file generation completed successfully.')
  logger.info('Script completed successfully.')
rescue StandardError => e
  logger.error("An error occurred: #{e.message}")
  logger.debug("Backtrace: #{e.backtrace}")
end
