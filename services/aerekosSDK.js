const fs = require('fs');
const { public } = require('./httpService');

const AEREKOS_PRIMARY_SERVER = process.env.AEREKOS_PRIMARY_SERVER;

const checkIfDeviceLocalRegistered = async () => {
    return process.env.AEREKOS_API_KEY ? true : false;
};

const connectToAerekosPrimary = async (hostIp) => {
    const primaryServerUrl = process.env.AEREKOS_PRIMARY_SERVER;
    console.log(`Connecting to Aerekos Primary Server at ${primaryServerUrl} from host IP ${hostIp}`);

    const url = `${AEREKOS_PRIMARY_SERVER}/devices/register`;
    console.log(`Sending registration request to ${url}`);
    const response = await public.post(url, { ip: hostIp, api_key: process.env.AEREKOS_API_KEY });
    const data = response;
    console.log('Response from Primary Server:', data);

    return data;
}

module.exports = {
    checkIfDeviceLocalRegistered,
    connectToAerekosPrimary
};