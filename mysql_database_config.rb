# frozen_string_literal: true

# class for generating the mysql config if it doesn't exist
require 'json'

# class for generating our config
class MysqlDatabaseConfig
  def initialize(config_file)
    @config_file = config_file
  end

  def generate
    if File.exist?(@config_file)
      puts 'Config file already exists, skipping generation.'
    else
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
      puts "Config file generated: #{@config_file}"
    end
  end

  private

  def prompt(message, default: nil)
    print message.to_s
    print " [#{default}]" if default
    print ': '
    value = gets.chomp
    value.empty? ? default : value
  end

  def prompt_bool(message, default: false)
    prompt("#{message} (y/n)", default: default) =~ /y|yes/i
  end
end
