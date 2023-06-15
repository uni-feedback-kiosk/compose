#!/bin/bash

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
sed -i "$SED_COMMAND" .env ppfs.yaml
