const assert = require('assert');
const http = require('http');
const app = require('../app');

describe('app test', () => {
    it('should return 200 status code', done => {
        http.get('http://localhost:3000/', res => {
            console.log('res', res.statusCode);
            assert.equal(200, res.statusCode);
            app.server.close();
            done();
        })
    });
});