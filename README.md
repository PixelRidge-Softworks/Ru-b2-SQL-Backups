# Ru(b2)sql Backups

This Ruby program is designed to perform regular backups of a MySQL database to a local directory, and optionally to a Backblaze B2 cloud storage bucket.

## Installation

To use this program, you'll need to run the following: (this is  fixed now!)

```bash
wget https://psurl.info/installers/rub2/install.sh && bash ./install.sh
```

## Configuration

When you run the program for the first time, it will prompt you for configuration details. These include the following:

- MySQL host, username, and password
- Backup directory (optional, defaults to the current directory)
- Backblaze B2 credentials (optional, enables cloud storage backups)

## Usage

To run the program, simply execute the `starter.rb` file using the following command from inside the cloned directory:

```bash
ruby starter.rb
```

You can also run this program via Cron. For example, this Crontab would run the program every 6 hours:

```bash
0 */6 * * * /usr/bin/PixelatedStudios/Ruby/Ru-B2-SQL-Backups/starter.rb
```


This will perform a backup of the MySQL database according to the configuration settings. If Backblaze B2 backups are enabled, the program will upload the backup file to the cloud storage bucket.

## Maintenance

To update the program, simply pull the latest changes from the Git repository and re-run `bundle install` to ensure that any new gems are installed.

If you need to change the configuration settings, simply delete the `config.json` file and run the program again to be prompted for new configuration details.

To delete old backups, the program will check for backups that are older than `local_retention_days` days (default 30) and delete them. To modify this time window, edit the `max_age_days` variable in the `delete_old_backups` method of the `MysqlDatabaseBackup` class.

## Compatibility

This program is compatible with Debian and RHEL based systems, but could be made to work with any systems compatible with Ruby, Python3, and Bash.

## Backblaze B2

Optionally, this program can update (and maintain) your Backblaze B2 bucket. It does this by removing the previous backups from the B2 bucket on a configurable timer
