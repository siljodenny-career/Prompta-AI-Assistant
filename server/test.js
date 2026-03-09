require('dotenv').config();
console.log('Key evaluated:', process.env.OPENROUTER_API_KEY);

const axios = require('axios');

axios.post(
    'https://openrouter.ai/api/v1/chat/completions',
    { model: 'openai/gpt-4o-mini', messages: [{ role: 'user', content: 'hello' }] },
    { headers: { Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`, 'Content-Type': 'application/json' } }
)
    .then(res => console.log('Success:', res.data.choices[0].message.content))
    .catch(err => console.error('Error:', err.response ? err.response.data : err.message));
