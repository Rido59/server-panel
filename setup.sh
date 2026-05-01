#!/bin/bash

# ==============================================================================
#  SERVERPANEL PRO v3.0 - KURULUM SCRIPTı
#  Modern, Güçlü ve Güvenli Sunucu Yönetim Paneli
# ==============================================================================

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}"
echo "  ⚡ SERVERPANEL PRO v3.0 KURULUYOR..."
echo "  ══════════════════════════════════════════════"
echo -e "${NC}"

# Root kontrolü
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}HATA: Bu script root yetkisiyle çalıştırılmalıdır.${NC}" 
   exit 1
fi

# Bağımlılıkları Yükle
echo -e "${BLUE}[1/5] Sistem paketleri güncelleniyor...${NC}"
apt-get update -y > /dev/null

echo -e "${BLUE}[2/5] Bağımlılıklar yükleniyor (Node.js, MySQL, Nginx, Certbot)...${NC}"
curl -sL https://deb.nodesource.com/setup_18.x | bash - > /dev/null
apt-get install -y nodejs mysql-server nginx certbot python3-certbot-nginx ghostscript git > /dev/null

# Veritabanı Yapılandırması
echo -e "${BLUE}[3/5] MySQL yapılandırılıyor...${NC}"
# Rastgele şifre oluştur
DB_PASS=$(openssl rand -base64 12)
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';"
mysql -e "FLUSH PRIVILEGES;"

# Panel Dosyalarını Kopyala
echo -e "${BLUE}[4/5] Panel dosyaları hazırlanıyor...${NC}"
mkdir -p /opt/server-panel
cp -r . /opt/server-panel/
cd /opt/server-panel

# Admin şifresini ayarla
cat <<EOF > panel-config.json
{
  "admin_user": "admin",
  "admin_pass": "admin",
  "mysql_root_pass": "$DB_PASS",
  "port": 3000
}
EOF

# NPM Paketlerini Yükle
echo -e "${BLUE}[5/5] Node.js bağımlılıkları yükleniyor...${NC}"
npm install --omit=dev > /dev/null

# Systemd Servisi Oluştur
cat <<EOF > /etc/systemd/system/server-panel.service
[Unit]
Description=ServerPanel Pro Service
After=network.target mysql.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/server-panel
ExecStart=/usr/bin/node server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable server-panel
systemctl start server-panel

# IP Adresini Al
IP_ADDR=$(hostname -I | awk '{print $1}')

echo -e "${GREEN}"
echo "  ✅ KURULUM BAŞARIYLA TAMAMLANDI!"
echo "  ══════════════════════════════════════════════"
echo -e "${NC}"
echo -e "${CYAN}Panel Adresi  :${NC} http://$IP_ADDR:3000"
echo -e "${CYAN}Kullanıcı Adı :${NC} admin"
echo -e "${CYAN}Şifre         :${NC} admin"
echo -e "${YELLOW}MySQL Root Şifresi:${NC} $DB_PASS"
echo -e ""
echo -e "${BLUE}Not: Lütfen MySQL şifresini güvenli bir yere kaydedin.${NC}"
echo -e "      Paneldeki tüm özellikler şu an aktif durumdadır."
echo -e ""
echo -e "${GREEN}ServerPanel Pro ile sunucunuz güvende!${NC}"
