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

      b2_enabled = prompt_bool('Enable Backblaze B2?', default: false)
      config['b2_enabled'] = b2_enabled
      if b2_enabled
        config['b2'] = {
          'key_id' => @b2_key_id,
          'application_key' => @b2_application_key,
          'bucket_name' => @b2_bucket_name
        }
      end

      config = {
        'mysql' => {
          'host' => mysql_host,
          'username' => mysql_username,
          'password' => mysql_password
        },
        'backup_dir' => backup_dir
      }

      if b2_enabled
        config['b2'] = {
          'key_id' => @b2_key_id,
          'application_key' => @b2_application_key,
          'bucket_name' => @b2_bucket_name
        }
      end

      File.write(@config_file, JSON.pretty_generate(config))
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
