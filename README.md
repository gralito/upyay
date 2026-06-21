# upyay v4.0.0

System updater for Arch-based systems using yay.

## Features

- **On-demand Updates & Mirror's List Refreshing**
- **Visual Notifications**
- **Cache & Journal Cleaning**
- **AutoBackup**
- **Display & Save Updated Packages List**
- **Configurable**

## Changelog

**v4.0.0**
- display the last updated packages list  
- configurable systemd journal cleaning vaccuum time

## Requirements

The following packages are required:
- `bash`            : of course
- `yay`				: AUR package management
- `notify-send` 	: desktop notifications
- `dunst`           : pimp your notifications
- `moreutils`       : provides `ifne` function, used in the script.

## Installation / Uninstallation

```bash
    yay -S upyay    #install
    yay -R upyay    #uninstall
```

## Use

### Fonctionnalities :  

**1. System update** :  
performs a complete update of your system  

```bash
upyay -u
upyay --update
```  
instead of
```bash
yay -Syyu --noconfirm --sudoloop --needed
```



**2. Refresh mirrors list** :  

updates the AUR mirrors list. if the `ENDEAVOUROS_OPTION`  
in the config file is set to `true`, it will also update the  
EndeavourOS mirrors list.  
```bash
upyay -m
upyay --mirrors
```
instead of
```bash
sudo reflector --protocol https --verbose --latest 25 --sort rate --save /etc/pacman.d/mirrorlist
  
eos-rankmirrors --verbose # if the option is enabled.  
```

**3. Clean journal** :  

cleans the systemd journal file and keeps only the last 4 weeks entries.  
```bash
upyay -j
upyay --journal
```
instead of
```bash
sudo journalctl --vacuum-time=4weeks
```

**4. Clean cache** :  

removes any package in the cache.  
```bash
upyay -c
upyay --cache
```
instead of
```bash
yay -Scc --noconfirm
```

**5. Remove orphans** :  

removes any orphan package from the system (at your own risk).  
please read the packages list before completing the task.  
```bash
upyay -o
upyay --orphans
```
instead of
```bash
sudo pacman -Qdtq | ifne sudo pacman -Rns
```

**6. Last actions** :

displays, for each feature, the date of the last use.

```bash
upyay -l
upyay --last
```

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

### Auto save updated

This option enables the auto save of the updated packages list in a file.  
If disabled, you will be prompted.

## Logs

Detailed information about updates is stored in `~/.logs/upyay/upyay.log`

## Security Considerations

- This script runs with sudo privileges to perform system updates
- Consider the security implications of automatic updates and passwordless sudo
- This is primarily designed for personal desktop systems with a single user

## History

**v3.2.0**
- bugfixing
- log issue fixed

**v3.1.4**
- fix permissions issues

**v3.1.3**
- various tests

**v3.1.2**  
- bugs fix
- pkgbuild corrections

**v3.1.1**
- bugs correction  
- update PKGBUILD - remove `sudo`  
- remove --no-confirm from commands  

**v3.1.0**
- you can display a summary of the updated packages  
- a new option is added to auto-display this summary  

**v3.0.0**
- short and long arguments version  
---

2026 by gralito
