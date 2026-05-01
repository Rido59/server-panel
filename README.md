# ServerPanel Pro v3.0 ⚡

ServerPanel Pro, modern sunucu yönetimi için geliştirilmiş, **Glassmorphism** temalı, profesyonel ve hafif bir kontrol panelidir. CPanel ve Plesk'e modüler, hızlı ve şık bir alternatif sunar.

![Banner](https://img.shields.io/badge/ServerPanel-Pro_v3.0-blue?style=for-the-badge&logo=linux)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## ✨ Özellikler

- **💎 Premium UI:** Tamamen Glassmorphism odaklı, dinamik ve modern bir kullanıcı arayüzü.
- **🗄️ Veritabanı Yönetimi:** MySQL Shell üzerinden gerçek zamanlı veritabanı CRUD işlemleri.
- **🔒 SSL Sertifikaları:** Let's Encrypt (Certbot) entegrasyonu ile tek tıkla SSL yönetimi.
- **🖥️ Web Terminal:** Doğrudan tarayıcı üzerinden SSH erişimi (Real-time PTY).
- **📧 E-posta & FTP:** Sistem entegre e-posta hesapları ve kullanıcı tabanlı FTP yönetimi.
- **📊 Gelişmiş Metrikler:** CPU, RAM ve Disk kullanımı için anlık görselleştirme.
- **🛠️ Otomatik Kurulum:** Tek komutla tüm bağımlılıkları yükleyen profesyonel kurulum betiği.

## 🚀 Hızlı Kurulum (Ubuntu/Debian)

Paneli sunucunuza kurmak için aşağıdaki komutları çalıştırmanız yeterlidir:

```bash
git clone https://github.com/Rido59/server-panel.git
cd server-panel
chmod +x setup.sh
sudo ./setup.sh
```

## 🛠️ Teknoloji Yığını

- **Backend:** Node.js, Express
- **Sistem:** Systeminformation, Child Process Entegrasyonu
- **Frontend:** Vanilla HTML5, Modern CSS (Glassmorphism), JavaScript (Async API)
- **Güvenlik:** Basic Auth, Protected API Routes

## 🔑 Kullanım

Kurulum tamamlandıktan sonra panelinize varsayılan bilgilerle giriş yapabilirsiniz:

- **Erişim:** `http://sunucu-ip:3000`
- **Kullanıcı:** `admin`
- **Parola:** `admin` (Kurulumdan sonra değiştirmeniz önerilir)

## 🤝 Katkıda Bulunma

1. Bu depoyu fork edin.
2. Yeni bir feature branch oluşturun (`git checkout -b feature/amazing-feature`).
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`).
4. Branch'inizi push edin (`git push origin feature/amazing-feature`).
5. Bir Pull Request açın.

---
**ServerPanel Pro** — Sunucunuzu şıklıkla yönetin. Made with ❤️ by Rido59.
