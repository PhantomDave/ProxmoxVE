#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/PhantomDave/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: PhantomDave
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Doezer/Questarr

APP="Questarr"
var_tags="${var_tags:-media;arr}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/questarr ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if ! command -v node >/dev/null || [[ "$(/usr/bin/env node -v | grep -oP '^v\K[0-9]+')" != "20" ]]; then
    NODE_VERSION="20" setup_nodejs
  fi

  if check_for_gh_release "Questarr" "Doezer/Questarr"; then
    msg_info "Stopping Service"
    systemctl stop questarr
    msg_ok "Stopped Service"

    msg_info "Backing up data"
    cp /opt/questarr/.env /opt/.env.backup
    msg_ok "Data backed up"

    msg_info "Updating ${APP}"
    cd /opt/questarr
    git fetch origin
    LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")
    git checkout "$LATEST_TAG"
    $STD npm ci --omit=dev
    $STD npm run build
    mv /opt/.env.backup /opt/questarr/.env
    msg_ok "Updated ${APP} to ${LATEST_TAG}"

    msg_info "Running Database Migrations"
    $STD npm run db:migrate
    msg_ok "Database Migrations Complete"

    msg_info "Starting Service"
    systemctl start questarr
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:5000${CL}"
