# B2 Ru(by)sql Backups

This Ruby program is designed to perform regular backups of a MySQL database to a local directory, and optionally to a Backblaze B2 cloud storage bucket.

## Known Issue

Currently the program is not uploading to B2, I'm trying to figure out why, but it's not presenting an error, even with debug code. Please bare with me.


## Installation

To use this program, you'll need to run the following:

```
wget https://rusql.pixelatedstudios.net/installers/rusql/db-backup.sh && bash ./db-backup.sh
```


## Configuration

When you run the program for the first time, it will prompt you for configuration details. These include the following:

- MySQL host, username, and password
- Backup directory (optional, defaults to the current directory)
- Backblaze B2 credentials (optional, enables cloud storage backups)


## Usage

To run the program, simply execute the `starter.rb` file using the following command from inside the cloned directory:

```
ruby starter.rb
```

You can also run this program via Cron. For example, this Crontab would run the program every 6 hours:

```
0 */6 * * * /path/to/starter.rb
```


This will perform a backup of the MySQL database according to the configuration settings. If Backblaze B2 backups are enabled, the program will upload the backup file to the cloud storage bucket.


## Maintenance

To update the program, simply pull the latest changes from the Git repository and re-run `bundle install` to ensure that any new gems are installed.

If you need to change the configuration settings, simply delete the `config.json` file and run the program again to be prompted for new configuration details.

To delete old backups, the program will check for backups that are older than 48 hours and delete them. To modify this time window, edit the `max_age_hours` variable in the `delete_old_backups` method of the `MysqlDatabaseBackup` class.


## Compatibility

This program is compatible with Debian and RHEL based systems, but could be made to work with any systems compatible with Ruby, Python3, and Bash.


## Backblaze B2

Optionally, this program can update (and maintain) your Backblaze B2 bucket. It does this by removing the previous backup from the B2 bucket when it uploads a new one.
