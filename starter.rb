# frozen_string_literal: true

require_relative 'mysql_database_config'
require_relative 'mysql_database_backup'
require_relative 'loggman'

config_file = 'config.json'
logger = Loggman.new

begin
  logger.info('Starting script.')

  config_generator = MysqlDatabaseConfig.new(config_file)
  config_generator.generate
  logger.info("Generated MySQL database configuration file: #{config_file}.")

  backup = MysqlDatabaseBackup.new(config_file)
  backup.backup
  logger.info('Performed MySQL database backup.')

  logger.info('Script completed successfully.')
rescue StandardError => e
  logger.error("An error occurred: #{e.message}")
  logger.debug("Backtrace: #{e.backtrace}")
end
