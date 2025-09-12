const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');

const app = express();
const port = 3000;

// PostgreSQL connection
const pool = new Pool({
  user: 'classkart_user',
  host: 'docker-postgres-1', // Changed from 'localhost'
  database: 'classkart_dev',
  password: 'classkart_pass',
  port: 5432,
});

pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Redis connection
const redisClient = redis.createClient({
  url: 'redis://docker-redis-1:6379', // Updated to use container name
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));

(async () => {
  await redisClient.connect();
  console.log('Redis connected');
})();

app.get('/health', async (req, res) => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    const time = result.rows[0];
    client.release();
    res.json({ status: 'OK', dbTime: time.now, redis: await redisClient.ping() });
  } catch (err) {
    res.status(500).json({ status: 'ERROR', message: err.message });
  }
});

app.listen(port, () => {
  console.log(`API listening at http://localhost:${port}`);
});