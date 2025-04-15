const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware to parse JSON
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Example endpoint 1
app.get('/api/example1', (req, res) => {
  res.json({
    message: 'This is example endpoint 1',
    timestamp: new Date().toISOString()
  });
});

// Example endpoint 2
app.get('/api/example2', (req, res) => {
  res.json({
    message: 'This is example endpoint 2',
    timestamp: new Date().toISOString(),
    data: {
      items: [
        { id: 1, name: 'Item 1' },
        { id: 2, name: 'Item 2' },
        { id: 3, name: 'Item 3' }
      ]
    }
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Node.js API listening at http://localhost:${port}`);
});
