const express = require('express');
const cors = require('cors');

const app = express();
const port = 4000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
     title: 'IU Cloud Programming Project',
     body: 'My name is Ibe, Christopher Obinna'

});
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
