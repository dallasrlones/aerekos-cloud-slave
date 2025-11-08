const fs = require('fs');
const { public } = require('./httpService');

const AEREKOS_PRIMARY_SERVER = process.env.AEREKOS_PRIMARY_SERVER;

const checkIfDeviceLocalRegistered = async () => {
    return process.env.AEREKOS_API_KEY ? true : false;
};

const connectToAerekosPrimary = async (hostIp, deviceSpecs = {}) => {
    const primaryServerUrl = process.env.AEREKOS_PRIMARY_SERVER;
    console.log(`Connecting to Aerekos Primary Server at ${primaryServerUrl} from host IP ${hostIp}`);

    const url = `${AEREKOS_PRIMARY_SERVER}/devices/register`;
    console.log(`Sending registration request to ${url}`);
    
    // Prepare registration payload with device info and specs
    const payload = {
        ip: hostIp,
        api_key: process.env.AEREKOS_API_KEY,
        name: deviceSpecs.hostname || 'unknown',
        specs: {
            hostname: deviceSpecs.hostname || 'unknown',
            os: deviceSpecs.os || 'unknown',
            os_name: deviceSpecs.os_name || deviceSpecs.os || 'unknown',
            os_version: deviceSpecs.os_version || 'unknown',
            architecture: deviceSpecs.architecture || 'unknown',
            memory_gb: deviceSpecs.memory_gb || 0,
            cpu: deviceSpecs.cpu || {
                model: 'unknown',
                cores: 0
            }
        }
    };
    
    console.log('Registration payload:', JSON.stringify(payload, null, 2));
    
    const response = await public.post(url, payload);
    const data = response;
    console.log('Response from Primary Server:', data);

    return data;
}

module.exports = {
    checkIfDeviceLocalRegistered,
    connectToAerekosPrimary
};