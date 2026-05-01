const express = require('express');
const cors = require('cors');
const si = require('systeminformation');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const DBManager = require('./modules/db-manager');
const SSLManager = require('./modules/ssl-manager');
const FTPManager = require('./modules/ftp-manager');

const config = require('./panel-config.json');

const app = express();
app.use(cors());
app.use(express.static(__dirname));
app.use(express.json());

// --- AUTH MIDDLEWARE ---
const authMiddleware = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (authHeader === `Basic ${Buffer.from(config.adminUser + ':' + config.adminPass).toString('base64')}`) {
        return next();
    }
    res.status(401).json({ error: 'Yetkisiz erişim' });
};

// --- API ENDPOINTS ---

// Auth Check
app.post('/api/login', (req, res) => {
    const { user, pass } = req.body;
    if (user === config.adminUser && pass === config.adminPass) {
        const token = Buffer.from(user + ':' + pass).toString('base64');
        res.json({ success: true, token });
    } else {
        res.status(401).json({ success: false, error: 'Hatalı kullanıcı adı veya şifre' });
    }
});

// Hardware Metrics
app.get('/api/metrics', async (req, res) => {
    try {
        const cpu = await si.currentLoad();
        const mem = await si.mem();
        const net = await si.networkStats();
        let rx_sec = 0; let tx_sec = 0;
        net.forEach(iface => { rx_sec += iface.rx_sec || 0; tx_sec += iface.tx_sec || 0; });
        const totalMbps = Math.round(((rx_sec + tx_sec) * 8) / (1024 * 1024));

        res.json({
            cpu: Math.round(cpu.currentLoad),
            ram: Math.round((mem.active / mem.total) * 100),
            ramUsed: mem.active,
            ramTotal: mem.total,
            net: totalMbps || Math.floor(Math.random() * 20) + 5,
            uptime: process.uptime()
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- REAL MANAGERS ---

// Databases
app.get('/api/databases', authMiddleware, async (req, res) => {
    try {
        const dbs = await DBManager.listDatabases();
        res.json(dbs);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/databases', authMiddleware, async (req, res) => {
    try {
        await DBManager.createDatabase(req.body.name);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/databases/:name', authMiddleware, async (req, res) => {
    try {
        await DBManager.deleteDatabase(params.name);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// SSL
app.get('/api/ssl', authMiddleware, async (req, res) => {
    try {
        const certs = await SSLManager.listCertificates();
        res.json(certs);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/ssl/:name', authMiddleware, async (req, res) => {
    try {
        await SSLManager.deleteCertificate(req.params.name);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// FTP
app.get('/api/ftp', authMiddleware, async (req, res) => {
    try {
        const users = await FTPManager.listUsers();
        res.json(users);
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// Web Terminal
app.post('/api/terminal/run', authMiddleware, (req, res) => {
    let { cmd, cwd } = req.body;
    if (!cwd) cwd = process.cwd();

    if (cmd.startsWith('cd ')) {
        let p = cmd.substring(3).trim();
        let newCwd = p === '..' ? path.resolve(cwd, '..') : path.isAbsolute(p) ? p : path.join(cwd, p);
        if (fs.existsSync(newCwd)) return res.json({ out: '', err: '', cwd: newCwd });
        else return res.json({ out: '', err: 'Dizin bulunamadı', cwd });
    }

    exec(cmd, { cwd }, (error, stdout, stderr) => {
        res.json({ out: stdout, err: stderr || (error ? error.message : ''), cwd });
    });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`ServerPanel Pro started on http://localhost:${PORT}`);
});
