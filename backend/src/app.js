require('dotenv').config();
process.on('unhandledRejection', (err) => {
  console.error('Unhandled rejection:', err.message);
});
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const connectDB = require('./config/db');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

connectDB();

app.use(cors());
app.use(express.json());

app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/family', require('./routes/family.routes'));

app.get('/health', (_, res) => res.json({ status: 'ok' }));

require('./socket/location.socket')(io);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
