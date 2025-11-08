const express = require('express');
const { connectToAerekosPrimary } = require('./services/aerekosSDK');

const aerekosHost = process.env.AREKOS_HOST;
const HOST_IP = process.env.HOST_IP;
const PORT = process.env.PORT;
const DEVICE_SPECS_RAW = process.env.DEVICE_SPECS;

const server = express();
server.use(express.json());
server.use(express.urlencoded({ extended: true }));

server.get('/', (_req, res) => {
  res.send('online');
});

server.listen(PORT, '0.0.0.0', async () => {
  console.log(`Aerekos Host: ${aerekosHost}`);
  console.log(`Host LAN IP: ${HOST_IP}`);
  console.log(`Server → http://${HOST_IP}:${PORT}`);

  // Parse device specs
  let deviceSpecs = {};
  try {
    deviceSpecs = DEVICE_SPECS_RAW ? JSON.parse(DEVICE_SPECS_RAW) : {};
    console.log('Device Specs:', JSON.stringify(deviceSpecs, null, 2));
  } catch (error) {
    console.error('Failed to parse device specs:', error.message);
    deviceSpecs = {
      hostname: 'unknown',
      os: 'unknown',
      os_version: 'unknown',
      architecture: 'unknown',
      memory_gb: 0,
      cpu: {
        model: 'unknown',
        cores: 0
      }
    };
  }

  try {
    const response = await connectToAerekosPrimary(HOST_IP, deviceSpecs);
    console.log('Registration response:', response);
  } catch (error) {
    console.error('Failed to connect to Aerekos Primary:', error.message);
  }
});