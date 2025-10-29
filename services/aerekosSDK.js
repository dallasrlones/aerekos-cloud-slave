const fs = require('fs');
const { public } = require('./httpService');

const AEREKOS_PRIMARY_SERVER = process.env.AEREKOS_PRIMARY_SERVER;

const checkIfDeviceLocalRegistered = async () => {
    try {
        const data = await fs.promises.readFile('./.unique_key', 'utf8');
        const device_id = data.trim();
        if (device_id.length > 0) {
            return device_id;
        } else {
            return false;
        }
    } catch (err) {
        return false;
    }
};

const connectToAerekosPrimary = async (hostIp) => {
    const primaryServerUrl = process.env.AEREKOS_PRIMARY_SERVER;
    console.log(`Connecting to Aerekos Primary Server at ${primaryServerUrl} from host IP ${hostIp}`);

    const url = `${AEREKOS_PRIMARY_SERVER}/devices/register`;
    console.log(`Sending registration request to ${url}`);
    const response = await public.post(url, { device: { ip: hostIp } });
    const data = response;
    console.log('Response from Primary Server:', data);

    return data;
}

module.exports = {
    checkIfDeviceLocalRegistered,
    connectToAerekosPrimary
};