const jwt = require('jsonwebtoken');

function gerarToken(cliente, secretKey) {
  const now = Math.floor(Date.now() / 1000);
  const expiresIn = 3600; // 1 hora

  const payload = {
    sub: cliente.id,
    email: cliente.email,
    role: 'Cliente',
    iat: now,
    exp: now + expiresIn,
    iss: 'oficina-mecanica-lambda',
    aud: 'mecanica-cliente'
  };

  const token = jwt.sign(payload, secretKey, { algorithm: 'HS256' });

  return { token, expiresIn };
}

module.exports = { gerarToken };
