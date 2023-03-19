# frozen_string_literal: true

require_relative 'mysql_database_config'
require_relative 'mysql_database_backup'

config_file = 'config.json'

config_generator = MysqlDatabaseConfig.new(config_file)
config_generator.generate

backup = MysqlDatabaseBackup.new(config_file)
backup.backup
