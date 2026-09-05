const jwt = require('jsonwebtoken');
const { gerarToken } = require('../../src/auth/jwtGenerator');

const SECRET_KEY = 'test-secret-key-com-minimo-32-caracteres';

const clienteMock = {
  id: 'uuid-123',
  email: 'joao@email.com'
};

describe('gerarToken', () => {

  test('deve retornar token e expiresIn', () => {
    const result = gerarToken(clienteMock, SECRET_KEY);

    expect(result).toHaveProperty('token');
    expect(result).toHaveProperty('expiresIn', 3600);
  });

  test('token deve ser uma string JWT válida', () => {
    const { token } = gerarToken(clienteMock, SECRET_KEY);

    expect(typeof token).toBe('string');
    expect(token.split('.')).toHaveLength(3);
  });

  test('payload deve conter as claims corretas', () => {
    const { token } = gerarToken(clienteMock, SECRET_KEY);
    const decoded = jwt.decode(token);

    expect(decoded.sub).toBe(clienteMock.id);
    expect(decoded.email).toBe(clienteMock.email);
    expect(decoded.role).toBe('Cliente');
    expect(decoded.iss).toBe('oficina-mecanica-lambda');
  });

  test('token deve expirar em 1 hora', () => {
    const before = Math.floor(Date.now() / 1000);
    const { token } = gerarToken(clienteMock, SECRET_KEY);
    const decoded = jwt.decode(token);

    expect(decoded.exp - decoded.iat).toBe(3600);
    expect(decoded.iat).toBeGreaterThanOrEqual(before);
  });

  test('deve usar algoritmo HS256', () => {
    const { token } = gerarToken(clienteMock, SECRET_KEY);
    const header = JSON.parse(Buffer.from(token.split('.')[0], 'base64').toString());

    expect(header.alg).toBe('HS256');
  });

  test('token deve ser inválido com secret errado', () => {
    const { token } = gerarToken(clienteMock, SECRET_KEY);

    expect(() => jwt.verify(token, 'secret-errado')).toThrow();
  });
});
