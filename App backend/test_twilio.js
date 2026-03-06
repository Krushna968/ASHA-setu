require('dotenv').config();
const twilio = require('twilio');

const twilioClient = twilio(
    process.env.TWILIO_ACCOUNT_SID,
    process.env.TWILIO_AUTH_TOKEN
);

async function testTwilio() {
    try {
        console.log('Using SID:', process.env.TWILIO_ACCOUNT_SID);
        console.log('Using Phone:', process.env.TWILIO_PHONE_NUMBER);

        const message = await twilioClient.messages.create({
            body: 'Twilio Test from ASHA-Setu',
            from: process.env.TWILIO_PHONE_NUMBER,
            to: '+919321609760' // Testing with the user's number
        });

        console.log('Success! SID:', message.sid);
    } catch (error) {
        console.error('Twilio Error:', error.message);
        console.error('Code:', error.code);
        console.error('Status:', error.status);
    }
}

testTwilio();
