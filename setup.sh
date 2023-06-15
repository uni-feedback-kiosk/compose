#!/bin/bash

TEMPLATES_FOLDER="./templates"

REPOSITORY="uni-feedback-kiosk/app"
ASSET_NAME="uni-feedback-kiosk-app.AppImage"
TARGET_USER="kiosk"

USER_FOLDER="~${TARGET_USER}"
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

  echo "Configuring getty service"

  sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/

  SED_COMMAND=""
  for variable in TARGET_USER
  do
    SED_COMMAND+="s/\$${variable}/${!variable}/g; "
  done

  echo "Substituting variables"
  sudo sed "$SED_COMMAND" "${TEMPLATES_FOLDER}/autologin.conf" > /etc/systemd/system/getty@tty1.service.d/autologin.conf

  echo "Copying xinit script"
  sudo cp "${TEMPLATES_FOLDER}/.xinitrc" > "$USER_FOLDER"

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
  echo "${TEMPLATES_FOLDER}/ppfs.yaml"
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
  sed "$SED_COMMAND" "${TEMPLATES_FOLDER}/app.env" > "~${TARGET_USER}/.env"

  echo -e "Done\n"
}

download_app() {
  echo "Downloading the application to ${ASSET_PATH}"
  sudo -u "$TARGET_USER" wget --no-verbose --show-progress -O "$ASSET_PATH" "https://github.com/${REPOSITORY}/releases/latest/download/${ASSET_NAME}"
  sudo chmod +x "$ASSET_PATH"

  echo -e "Done\n"
}

steps=(configure_file_server configure_app create_user configure_launch download_app)
steps_count="${#steps[@]}"

for i in "${!steps[@]}"
do
  echo -n "[$((($i+1)))/${steps_count}] "
  ${steps[$i]}
done
