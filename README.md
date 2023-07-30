# Ru(b2)sql Backups

This Ruby program is designed to perform regular backups of a MySQL database to a local directory, and optionally to a Backblaze B2 cloud storage bucket.

Please put any feature suggestions into [Issues](https://github.com/PixelRidge-Softworks/Ru-b2-SQL-Backups/issues) and we will implement them if we can!
If you'd like to help with the development of Ru(b2)SQL Backups, you can clone this repository and then create a Pull Request. If we don't find any issues, we will merge the PR.

## Installation

To use this program, you'll need to run the following: (this is  fixed now!)
[Source](https://raw.githubusercontent.com/PixelRidge-Softworks/Installers/main/install.sh)

```bash
wget https://raw.githubusercontent.com/PixelRidge-Softworks/Installers/main/install.sh && bash ./install.sh
```

## Configuration

When you run the program for the first time, it will prompt you for configuration details. These include the following:

- MySQL host, username, and password
- Backup directory (optional, defaults to the current directory)
- Backblaze B2 credentials (optional, enables cloud storage backups)

## Usage

To run the program, simply execute the `./rub2` command from inside the cloned directory:

```bash
./rub2
```

You can also run this program via Cron. For example, this Crontab would run the program every 6 hours:

```bash
0 */6 * * * /usr/bin/PixelRidge-Softworks/Ruby/Ru-B2-SQL-Backups/rub2
```


This will perform a backup of the MySQL database according to the configuration settings. If Backblaze B2 backups are enabled, the program will upload the backup file to the cloud storage bucket.

## Maintenance

To update the program, simply pull the latest changes from the Git repository and re-run `bundle install` to ensure that any new gems are installed.

If you need to change the configuration settings, simply delete the `config.json` file and run the program again to be prompted for new configuration details.

~~To delete old backups, the program will check for backups that are older than `local_retention_days` days (default 30) and delete them. To modify this time window, edit the `max_age_days` variable in the `delete_old_backups` method of the `MysqlDatabaseBackup` class.~~

^^ This is no longer applicable, you can now set the retention time in the config.json

## Compatibility

This program is compatible with Debian and RHEL based systems, but could be made to work with any systems compatible with Ruby, Python3, and Bash.

This program was also built on Arch Linux, so it should also run fine on Manjaro, Arch, and any other Arch based distro.

## Backblaze B2

Optionally, this program can update (and maintain) your Backblaze B2 bucket. It does this by removing the previous backups from the B2 bucket on a configurable timer
