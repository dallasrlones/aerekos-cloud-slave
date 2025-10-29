const express = require('express');
const { checkIfDeviceLocalRegistered, connectToAerekosPrimary } = require('./services/aerekosSDK');

const aerekosHost = process.env.AREKOS_HOST;
const HOST_IP = process.env.HOST_IP;
const PORT = process.env.PORT;

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

  const registered = await checkIfDeviceLocalRegistered()
  if (registered == false) {
    console.log('Device not registered locally. Registering with Aerekos Primary Server...');
    const response = await connectToAerekosPrimary(HOST_IP);
    console.log('Registration response:', response);
  }
});