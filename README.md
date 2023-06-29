# Kiosk setup
<!-- markdownlint-disable MD024 -->

This repository helps to install and launch the kiosk system on Windows and Linux.

## Windows

### Description

`setup.ps1` goes through the following steps:

- Configure file server (set the admin credentials)
- Configure UI application (set SMTP credentials and path to the app)
- Create a restricted Windows kiosk user
  - User has no password and is logged on automatically at the OS boot
  - The application is launched automatically after the user is logged on
- Prompt to log into the new user and run another script, `setenv.ps1`

`setenv.ps1` sets the environment variables for the newly created user. The script must be run as administrator.

### Prerequisites

- Git (optional, would make updating this repository easier)
- [Windows Configuration Designer](https://www.microsoft.com/store/apps/9nblggh4tx22)
- [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/)
- The app itself ([uni-feedback-kiosk/app](https://github.com/uni-feedback-kiosk/app))

### How to setup the kiosk

- Clone the repo or download [the archive](https://github.com/uni-feedback-kiosk/setup/archive/refs/heads/master.zip) and extract it.
- Open PowerShell and run the `setup.ps1` script.
- After the user is created, log into it and switch back to the original user.
- Run `setenv.ps1` **as administrator** to set the environment variables for the newly created user.
- Run `docker compose up -d` to start Docker services.
- Reboot to check that the user is logged into automatically and the app is functioning properly.

> **Note**
> You may need to run `Unblock-File` on the scripts before running the scripts themselves.

## Linux

> **Warning**
>
> Latest versions of the kiosk app are not built for Linux.
>
> The setup script uses a fixed version of the application that is latest for Linux at the time of changing this.

### Description

`setup.sh` goes through the following steps:

- Create Linux user for kiosk
- Configure automatic app launch on system startup
- Configure file server (set the admin credentials)
- Configure UI application (set SMTP credentials)
- Install Docker (skipped if Docker is found)
- Download the UI app (skipped in the app is found)
- Launch Docker services and UI app

### Prerequisites

- Git (optional, would make updating this repository easier)

### How to run the script

If the target system has `git`, simply clone the repo and run `bash setup.sh`.

Otherwise, you can download the repository as an archive, and then run the script:

```bash
wget -O kiosk.zip "https://github.com/uni-feedback-kiosk/setup/archive/refs/heads/master.zip"
unzip kiosk.zip
cd setup-master
bash setup.sh
```
