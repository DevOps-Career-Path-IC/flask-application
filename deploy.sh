set -e
APP_PATH="/opt/flask_app"
VENV_PATH="/opt/flask_app/venv"

# Environment setup
if [ -d ${APP_PATH} ]; then
    sudo cp -r ${APP_PATH} ${APP_PATH}_backup_$(date +%Y%m%d_%H%M%S)
fi

sudo mkdir -p ${APP_PATH} || true

cd /tmp && sudo tar -xzf deploy.tar.gz -C ${APP_PATH}

# Runtime setup
if [ ! -d ${VENV_PATH} ]; then
    sudo python3 -m venv ${VENV_PATH}
fi

# Install necessary packages
sudo ${VENV_PATH}/bin/pip install -r ${APP_PATH}/api/requirements.txt
sudo ${VENV_PATH}/bin/pip install gunicorn

# Systemd configuration setup
SYSTEMD_FILE_LOCATION="/etc/systemd/system/flask_app.service"

sudo cp /tmp/flask_app.service ${SYSTEMD_FILE_LOCATION}
sudo systemctl daemon-reload
sudo systemctl enable flask_app.service
sudo systemctl restart flask_app.service

rm /tmp/deploy.tar.gz

