const express = require('express');
const constant = require('./const');
const app = express();
app.set('port', process.env.PORT || constant.PORT);

app.get('/', (req, res) => {
    res.send('Hello, Express');
});

const server = app.listen(app.get('port'), ()=>{
    console.log(app.get('port'), '번 포트에서 대기 중');
});

exports.server = server;