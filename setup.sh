#!/bin/bash

set -e  # 🔥 HATA OLURSA DUR

echo "⚡ SERVERPANEL PRO KURULUYOR..."

# root check
if [[ $EUID -ne 0 ]]; then
  echo "Root çalıştır"
  exit 1
fi

echo "[1] Sistem güncelleniyor..."
apt-get update -y

echo "[2] IPv4 zorla (repo hatası fix)"
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

echo "[3] Node kuruluyor..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

echo "[4] Diğer paketler..."
apt-get install -y nginx certbot python3-certbot-nginx ghostscript git mysql-server

echo "[5] MySQL başlatılıyor..."
systemctl enable mysql
systemctl start mysql

sleep 3

echo "[6] MySQL test..."
mysqladmin ping

# şifre üret
DB_PASS=$(openssl rand -base64 12)

echo "[7] MySQL root şifre set..."
mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';
FLUSH PRIVILEGES;
EOF

echo "[8] Panel kuruluyor..."
mkdir -p /opt/server-panel
cp -r . /opt/server-panel/
cd /opt/server-panel

cat <<EOF > panel-config.json
{
  "admin_user": "admin",
  "admin_pass": "$(openssl rand -base64 8)",
  "mysql_root_pass": "$DB_PASS",
  "port": 3000
}
EOF

echo "[9] NPM kuruluyor..."
npm install --omit=dev

echo "[10] Service oluşturuluyor..."
cat <<EOF > /etc/systemd/system/server-panel.service
[Unit]
Description=ServerPanel
After=network.target mysql.service

[Service]
Type=simple
WorkingDirectory=/opt/server-panel
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable server-panel
systemctl restart server-panel

IP=$(hostname -I | awk '{print $1}')

echo "✅ BİTTİ"
echo "Panel: http://$IP:3000"
echo "MySQL: $DB_PASS"
