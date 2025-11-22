import request from 'supertest';
import app from '../src/app.js';

describe('Healthcheck', () => {
  it('GET /healthz retorna ok', async () => {
    const res = await request(app).get('/healthz');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ ok: true });
  });
});