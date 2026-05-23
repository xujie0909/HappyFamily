const https = require('https');

async function reverseGeocode(lat, lng) {
  const key = process.env.AMAP_KEY;
  if (!key) return '未知位置';

  const url = `https://restapi.amap.com/v3/geocode/regeo?key=${key}&location=${lng},${lat}&radius=500&extensions=base&output=json`;

  return new Promise((resolve) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          if (result.status === '1' && result.regeocode?.formatted_address) {
            // Strip province prefix to keep address concise
            const addr = result.regeocode.formatted_address;
            const parts = result.regeocode.addressComponent;
            const short = [parts.city, parts.district, parts.township, parts.street, parts.streetNumber]
              .filter(Boolean).join('');
            resolve(short || addr);
          } else {
            resolve('未知位置');
          }
        } catch {
          resolve('未知位置');
        }
      });
    }).on('error', () => resolve('未知位置'));
  });
}

module.exports = { reverseGeocode };
