const { Pool } = require('pg');
const { ClienteNaoEncontradoError, ClienteInativoError } = require('../errors');

let pool = null;

function getPool(dbConfig) {
  if (!pool) {
    pool = new Pool({
      host: dbConfig.endpoint,
      port: dbConfig.port,
      database: dbConfig.dbName,
      user: dbConfig.username,
      password: dbConfig.password,
      max: 5,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
      ssl: { rejectUnauthorized: false }
    });
  }
  return pool;
}

async function buscarClientePorCpf(cpf, dbConfig) {
  const client = await getPool(dbConfig).connect();

  try {
      const result = await client.query(
      'SELECT "Id", "Email", "Ativo" FROM "Clientes" WHERE "Documento" = $1',
      [cpf]
    );

    if (result.rows.length === 0) {
      throw new ClienteNaoEncontradoError();
    }

    const cliente = result.rows[0];

    if (!cliente.ativo) {
      throw new ClienteInativoError();
    }

    return {
      id: cliente.id,
      email: cliente.email
    };
  } finally {
    client.release();
  }
}

module.exports = { buscarClientePorCpf };
