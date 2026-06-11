# upyay v3.0.0

System updater for Arch-based systems using yay.

## Features

- **On-demand updates & Mirror's list refreshing**
- **Visual Notifications**
- **Cache & Journal Cleaning**
- **AutoBackup**
- **Configurable**: Easy to configure through a config file
- **Quick mode**: Provides shortcuts (-short and --long) for each functionnality.

## Requirements

The following packages are required:
- `bash`            : of course
- `yay`				: AUR package management
- `notify-send` 	: desktop notifications
- `moreutils`       : provides `ifne` function, used in the script.

## Installation / Uninstallation

```bash
    yay -S upyay    #install
    yay -R upyay    #uninstall
```

## Use

You can 'upyay' your system in different ways :  
1. classic mode  
just run `upyay` and get guided by the program.  

2. quick mode  
if you wanna launch only one functionnality, you can use the 'quick mode'.  
To do so, run your program with a short or a long argument.  

### Fonctionnalities :  

**1. System update** :  
performs a complete update of your system  
```bash
yay -Syyu --noconfirm --sudoloop --needed
```

*Quick mode* : `upyay -u` or `upyay --update`

**2. Refresh mirrors list** :  

updates the AUR mirrors list. if the `ENDEAVOUROS_OPTION`  
in the config file is set to `true`, it will also update the  
EndeavourOS mirrors list.  

```bash
sudo reflector --protocol https --verbose --latest 25 --sort rate --save /etc/pacman.d/mirrorlist
  
eos-rankmirrors --verbose # if the option is enabled.  
```

Quick mode : `upyay -m` or `upyay --mirrors`

**3. Clean journal** :  

cleans the systemd journal file and keeps only the last 4 weeks entries.  

```bash
sudo journalctl --vacuum-time=4weeks
```

*Quick mode* : `upyay -j` or `upyay --journal`

**4. Clean cache** :  

removes any package in the cache.  

```bash
yay -Scc --noconfirm
```

*Quick mode* : `upyay -c` or `upyay --cache`  

**5. Remove orphans** :  

removes any orphan package from the system (at your own risk).  
please read the packages list before completing the task.  

```bash
sudo pacman -Qdtq | ifne sudo pacman -Rns
```

*Quick mode* : `upyay -o` or `upyay --orphans` 

**6. Last actions** :

displays, for each feature, the date of the last use.

*Quick mode* : `upyay -l` or `upyay --last`

## Configuration

A configuration file is created at `~/.config/upyay/config`  
where you can customize:

- Localization for your language
- Notification settings
- Icons
- Additionnal option if you're running EndeavourOS
- Auto-backup

### Language configuration

**Important**: If yay's output is not in English, you need to change  
the `NOTHING_TO_DO_STRING` in the configuration file to match  
your language's equivalent for "there is nothing to do".

### Notifications configuration

You can set the display duration. Default is set to 10000ms.  
You can also change the notifications icons.

### OS configuration

If you're running EndeavourOS, you can set this option to true.  
When performing the mirror's update, you will be asked if you  
also wanna refresh EOS mirrors list.

### Auto backup

If this option is set to true, you won't be asked if you wanna  
backup your log file, it will be done automatically.

## Logs

Detailed information about updates is stored in `~/.logs/upyay/upyay.log`

## Security Considerations

- This script runs with sudo privileges to perform system updates
- Consider the security implications of automatic updates and passwordless sudo
- This is primarily designed for personal desktop systems with a single user

## Upcoming

A new version will be prepared soon with a new feature :
- Any suggestion brought by you.
- Detailed summary of all updated packages
- Performs log rotation on pacman logs

---

2026 by gralito
