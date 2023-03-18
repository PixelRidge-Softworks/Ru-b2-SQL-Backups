# frozen_string_literal: true

require 'json'

# class for creating, managing and deleting backups both locally and in B2
class MysqlDatabaseBackup
  def initialize(config_file)
    config = JSON.parse(File.read(config_file))
    @host = config['mysql']['host']
    @username = config['mysql']['username']
    @password = config['mysql']['password']
    @backup_dir = config['backup_dir'] || '.'
    @b2_enabled = config['b2_enabled'] || false
    @b2_key_id = config['b2']&.dig('key_id')
    @b2_application_key = config['b2']&.dig('application_key')
    @b2_bucket_name = config['b2']&.dig('bucket_name')
  end

  def backup
    puts 'Backing up sql'
    timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    puts "Timestamp = #{timestamp}"
    backup_file = File.join(@backup_dir, "database-backup_#{timestamp}.sql")
    puts "backup_file = #{backup_file}"
    puts "MySQL Info = #{@host} #{@username} #{@password} #{backup_file}"

    `mysqldump --host=#{@host} --user=#{@username} --password='#{@password}' --all-databases > #{backup_file}`

    delete_old_backups

    return unless @b2_enabled

    upload_to_b2(backup_file)
  end

  def delete_old_backups
    max_age_hours = 48
    max_age_seconds = max_age_hours * 60 * 60
    backups = Dir[File.join(@backup_dir, 'database-backup_*.sql')]

    return if backups.empty?

    backups.each do |backup|
      age_seconds = Time.now - File.mtime(backup)

      if age_seconds > max_age_seconds
        puts "Deleted old backup: #{backup}"
        File.delete(backup)
      end
    end
  end

  def upload_to_b2(backup_file)
    b2_file_name = File.basename(backup_file)
    b2_file_url = "b2://#{@b2_bucket_name}/#{b2_file_name}"
    # Check if a backup file with the same name already exists in the B2 bucket

    existing_file = `b2-cli list-file-names #{@b2_bucket_name} --prefix #{b2_file_name}`
    if existing_file.include?(b2_file_name)
      # Delete the existing backup file from the B2 bucket
      file_version = existing_file.match(/"fileId": "([^"]+)"/)[1]
      `b2-cli delete-file-version #{@b2_bucket_name} #{b2_file_name} #{file_version}`
      puts "Deleted existing backup file from B2 bucket: #{b2_file_url}"
    end
    # Upload the backup file to the B2 bucket

    `b2-cli upload-file #{@b2_bucket_name} #{backup_file} #{b2_file_name}`
    puts "Uploaded backup file to B2 bucket: #{b2_file_url}"
  end
end
