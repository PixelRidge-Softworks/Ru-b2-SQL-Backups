# frozen_string_literal: true

require 'English'
require 'tty-prompt'
require 'tty-progressbar'
require 'sequel'
require 'open3'

prompt = TTY::Prompt.new

# Connect to the SQLite database
db = Sequel.sqlite('backups.db')

# Get a reference to the backups table
backups_table = db[:backups]

# Query the database for remote and local backups
remote_backups = backups_table.where(backup_type: 'remote').map(:backup_name)
local_backups = backups_table.where(backup_type: 'local').map(:backup_name)

# Define the categories with the queried lists
choices = [
  {
    name: 'Remote Backups',
    choices: remote_backups
  },
  {
    name: 'Local Backups',
    choices: local_backups
  }
]

user_choice = prompt.select('Choose a backup to restore:', choices)

# Determine if the chosen backup is local or remote
backup_type = backups_table.where(backup_name: user_choice).get(:backup_type)

if backup_type == 'remote'
  # Get the B2 bucket name
  b2_bucket_name = backups_table.where(backup_name: user_choice).get(:b2_bucket_name)

  # Download the remote backup from B2
  `./b2 download-file-by-name #{b2_bucket_name} #{user_choice} ./#{user_choice}`
end

# Perform a "dry run" of the SQL script
output = `mysql --host=#{mysql_host} --user=#{mysql_username} --password=#{mysql_password} your_database
          --execute="START TRANSACTION; SOURCE #{user_choice}; ROLLBACK;"`
if $CHILD_STATUS.success?
  prompt.say('SQL file passed the dry run.')
else
  prompt.say("Error in SQL file: #{output}")
  exit 1
end

# Create a progress bar
total_size = File.size(user_choice)
bar = TTY::ProgressBar.new('Restoring [:bar] :percent', total: total_size)

# Open the SQL file and the MySQL process
File.open(user_choice) do |file|
  sql_chunk = ''
  file.each_line do |line|
    sql_chunk += line
    # If the line ends with a semicolon and the chunk size is over 1024 bytes, execute the chunk
    next unless line.strip.end_with?(';') && sql_chunk.bytesize >= 1024

    # Write the chunk to the MySQL process
    `mysql --host=#{mysql_host} --user=#{mysql_username} --password=#{mysql_password} your_database
    --execute="#{sql_chunk}"`
    # Update the progress bar
    bar.advance(sql_chunk.bytesize)
    sql_chunk = ''
  end
  # Write the remaining SQL commands to the MySQL process
  unless sql_chunk.empty?
    `mysql --host=#{mysql_host} --user=#{mysql_username} --password=#{mysql_password} your_database
    --execute="#{sql_chunk}"`
    bar.advance(sql_chunk.bytesize)
  end
end

if $CHILD_STATUS.success?
  prompt.say('Import completed successfully.')
else
  prompt.say("Error during import: #{output}")
end

prompt.say("Backup #{user_choice} restored successfully.")
