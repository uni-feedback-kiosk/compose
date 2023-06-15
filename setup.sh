#!/bin/bash

TEMPLATES_FOLDER="./templates"

REPOSITORY="uni-feedback-kiosk/app"
ASSET_NAME="uni-feedback-kiosk-app.AppImage"
TARGET_USER="kiosk"

USER_FOLDER=$(eval echo ~$TARGET_USER)
ASSET_PATH="${USER_FOLDER}/${ASSET_NAME}"

create_user() {
  echo "Setting up kiosk user"

  if id "$TARGET_USER" >/dev/null 2>&1
  then
    echo -e "User '$TARGET_USER' already exists\n"
    return
  fi

  echo "Creating user '$TARGET_USER'"
  sudo adduser --disabled-login --shell /usr/bin/startx --gecos 'Kiosk User' "$TARGET_USER"

  echo -e "Done\n"
}

configure_launch() {
  echo "Configuring automatic app launch"

  echo "Configuring getty@tty1 service"
  CONFIG_FOLDER="/etc/systemd/system/getty@tty1.service.d/"
  sudo mkdir -p "$CONFIG_FOLDER"

  SED_COMMAND=""
  for variable in TARGET_USER
  do
    SED_COMMAND+="s/\$${variable}/${!variable}/g; "
  done

  echo "Substituting variables"
  sed "$SED_COMMAND" "${TEMPLATES_FOLDER}/autologin.conf" | sudo tee "${CONFIG_FOLDER}/autologin.conf" >/dev/null

  echo "Copying xinit script"
  sudo cp "${TEMPLATES_FOLDER}/.xinitrc" "$USER_FOLDER"

  echo "Reloading systemd services"
  sudo systemctl daemon-reload

  echo -e "Done\n"
}

configure_file_server() {
  echo "Configuring file server"

  JWT_KEY="$(openssl rand -hex 32)"

  DB_USERNAME="ppfs_db_$(openssl rand -hex 4)"
  DB_PASSWORD="$(openssl rand -hex 32)"

  echo -n "File server admin username: "
  read ADMIN_USERNAME

  ADMIN_PASSWORD="$(openssl rand -hex 32)"
  echo "File server admin password: $ADMIN_PASSWORD"

  USER_USERNAME="ppfs_user_$(openssl rand -hex 4)"
  USER_PASSWORD="$(openssl rand -hex 32)"

  SED_COMMAND=""
  for variable in JWT_KEY DB_USERNAME DB_PASSWORD ADMIN_USERNAME ADMIN_PASSWORD USER_USERNAME USER_PASSWORD
  do
    SED_COMMAND+="s/\$${variable}/${!variable}/g; "
  done

  echo "Substituting variables"
  sed "$SED_COMMAND" "${TEMPLATES_FOLDER}/.env" > .env
  sed "$SED_COMMAND" "${TEMPLATES_FOLDER}/ppfs.yaml" > ppfs.yaml

  echo -e "Done\n"
}

configure_app() {
  echo "Configuring the app"

  echo -n "SMTP hostname (without port): "
  read SMTP_HOST
  echo -n "SMTP port: "
  read SMTP_PORT
  echo -n "SMTP username: "
  read SMTP_USERNAME
  echo -n "SMTP password: "
  read SMTP_PASSWORD
  echo -n "SMTP recipient: "
  read SMTP_RECIPIENT

  SED_COMMAND=""
  for variable in ASSET_PATH SMTP_HOST SMTP_PORT SMTP_USERNAME SMTP_PASSWORD SMTP_RECIPIENT
  do
    SED_COMMAND+="s/\$${variable}/${!variable}/g; "
  done

  echo "Substituting variables"
  sed "$SED_COMMAND" "${TEMPLATES_FOLDER}/app.env" | sudo tee "~${TARGET_USER}/.env" >/dev/null

  echo -e "Done\n"
}

download_app() {
  echo "Downloading the application to ${ASSET_PATH}"
  sudo -u "$TARGET_USER" wget --no-verbose --show-progress -O "$ASSET_PATH" "https://github.com/${REPOSITORY}/releases/latest/download/${ASSET_NAME}"
  sudo chmod +x "$ASSET_PATH"

  echo -e "Done\n"
}

finish() {
  echo "Reboot to see if the configuration works fine."
}

steps=(create_user configure_launch configure_file_server configure_app download_app finish)
steps_count="${#steps[@]}"

for i in "${!steps[@]}"
do
  echo -n "[$((($i+1)))/${steps_count}] "
  ${steps[$i]}
done
