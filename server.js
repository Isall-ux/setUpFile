//The address of this server conected to the network is:
// URL -> http://localhost:8383
// the ip address equivelant is ->  127.0/0.1:8383

const express = require('express');
const app = express();

//this is the port number where the server will be listening
//think of it like this, your computer has one address (ip address) but many different doors(ports)
//each door can lead to a different service running on your computer

const PORT = 8383;

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});