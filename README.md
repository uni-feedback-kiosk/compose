# Kiosk setup

This repository helps to install and launch the kiosk system.

The setup script guides goes through the following steps:

- Create Linux user for kiosk
- Configure automatic app launch on system startup
- Configure file server (set the admin credentials)
- Configure UI application (set SMTP credentials)
- Install Docker (skipped if Docker is found)
- Download the UI app (skipped in the app is found)
- Launch Docker services and UI app

## How to run the script

If the target system has `git`, simply clone the repo and run `bash setup.sh`.

Otherwise, you can download the repository as an archive, and then run the script:

```bash
wget -O kiosk.zip "https://github.com/uni-feedback-kiosk/setup/archive/refs/heads/master.zip"
unzip kiosk.zip
cd setup-master
bash setup.sh
```
