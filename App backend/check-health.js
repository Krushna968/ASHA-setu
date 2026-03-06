const http = require('http');

function check() {
    http.get('http://localhost:5000/api/db-check', (res) => {
        let data = '';
        res.on('data', (chunk) => data += chunk);
        res.on('end', () => {
            console.log('Backend Status:', res.statusCode);
            console.log('Response:', data);
        });
    }).on('error', (err) => {
        console.error('Backend not reachable:', err.message);
    });
}

check();
