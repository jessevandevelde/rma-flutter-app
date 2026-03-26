const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 8000;

app.use(cors());
app.use(bodyParser.json());

// --- DATABASE ---
const db = new sqlite3.Database('./database.sqlite', (err) => {
    if (err) console.error('Database Error:', err.message);
    else console.log('Database verbonden.');
});

// Initialisatie van de twee tabellen met twee tickets
db.serialize(() => {
    // 1. Gebruikers tabel
    db.run("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, email TEXT, password TEXT)");
    db.run("INSERT OR IGNORE INTO users (id, email, password) VALUES (1, 'test@dmg.nl', 'welkom01')");

    // 2. Hoofdtabel: tickets
    db.run(`CREATE TABLE IF NOT EXISTS tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        category TEXT,
        ticketId TEXT UNIQUE,
        status TEXT DEFAULT 'OPEN',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // 3. Detailtabel: ticket_data
    db.run(`CREATE TABLE IF NOT EXISTS ticket_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_id_ref TEXT,
        description TEXT,
        product_name TEXT,
        serial_number TEXT,
        FOREIGN KEY(ticket_id_ref) REFERENCES tickets(ticketId)
    )`, () => {
        // UITLEG: We vullen de database met exact TWEE tickets zoals gevraagd.
        db.get("SELECT COUNT(*) as count FROM tickets", (err, row) => {
            if (row && row.count === 0) {
                console.log('>>> Database vullen met twee tickets...');

                // Ticket 1: MacBook
                const tId1 = '#USR-9999';
                db.run("INSERT INTO tickets (title, category, ticketId) VALUES (?, ?, ?)", ['Defect Scherm', 'Laptop', tId1]);
                db.run("INSERT INTO ticket_data (ticket_id_ref, description, product_name, serial_number) VALUES (?, ?, ?, ?)",
                [tId1, 'Barst in het scherm na val.', 'MacBook Pro 14', 'SN-12345']);

                // Ticket 2: Logitech Keyboard
                const tId2 = '#USR-8888';
                db.run("INSERT INTO tickets (title, category, ticketId) VALUES (?, ?, ?)", ['Toetsenbord hapert', 'Keyboard', tId2]);
                db.run("INSERT INTO ticket_data (ticket_id_ref, description, product_name, serial_number) VALUES (?, ?, ?, ?)",
                [tId2, 'Sommige toetsen reageren niet meer.', 'Logitech MX Keys', 'SN-67890']);
            }
        });
    });
});

// --- API ROUTES ---

app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    db.get("SELECT * FROM users WHERE email = ? AND password = ?", [email, password], (err, row) => {
        if (row) res.status(200).json({ message: 'OK', user: { email: row.email } });
        else res.status(401).json({ message: 'Fout' });
    });
});

// TICKETS OPHALEN MET DATA (JOIN)
// UITLEG: We halen data op uit beide tabellen.
app.get('/api/tickets', (req, res) => {
    const status = req.query.status || 'OPEN';
    const query = `
        SELECT t.*, d.description, d.product_name, d.serial_number
        FROM tickets t
        LEFT JOIN ticket_data d ON t.ticketId = d.ticket_id_ref
        WHERE t.status = ?
        ORDER BY t.id DESC
    `;
    db.all(query, [status], (err, rows) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json(rows || []);
    });
});

app.listen(port, '0.0.0.0', () => {
    console.log(`Server actief op poort ${port}`);
});
