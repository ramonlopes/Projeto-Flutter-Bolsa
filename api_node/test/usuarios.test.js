import request from 'supertest';
import app from '../src/app.js';
import sequelize from '../src/config/database.js';

beforeAll(async () => {
  await sequelize.authenticate();
  await sequelize.sync({ force: true }); // usa o Postgres do CI
});

afterAll(async () => {
  await sequelize.close();
});

describe('Usuarios API', () => {
  it('POST /usuarios cria e GET /usuarios lista', async () => {
    const novo = await request(app)
      .post('/usuarios')
      .send({ nome: 'Alice', email: 'alice@mail.com', senha: '123' })
      .set('Content-Type', 'application/json');
    expect(novo.status).toBe(201);
    expect(novo.body.email).toBe('alice@mail.com');

    const lista = await request(app).get('/usuarios');
    expect(lista.status).toBe(200);
    expect(Array.isArray(lista.body)).toBe(true);
    expect(lista.body.length).toBe(1);
    expect(lista.body[0].email).toBe('alice@mail.com');
  });
});