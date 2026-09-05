const { validarCpf } = require('./auth/cpfValidator');
const { gerarToken } = require('./auth/jwtGenerator');
const { buscarClientePorCpf } = require('./auth/clienteRepository');
const { getDbConfig, getJwtSecretKey } = require('./config/secrets');
const { CpfInvalidoError } = require('./errors');

function resposta(statusCode, body) {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  };
}

exports.handler = async (event) => {
  console.log('Evento recebido:', JSON.stringify(event));

  try {
    // Parse do body
    let body = {};
    try {
      body = JSON.parse(event.body || '{}');
    } catch {
      return resposta(400, { error: 'Body inválido' });
    }

    const { cpf } = body;

    // Validar presença do CPF
    if (!cpf) {
      return resposta(400, { error: 'CPF é obrigatório' });
    }

    // Validar formato e dígitos verificadores
    if (!validarCpf(cpf)) {
      throw new CpfInvalidoError();
    }

    // CPF limpo (apenas números)
    const cpfLimpo = String(cpf).replace(/\D/g, '');

    // Buscar configurações (com cache em warm Lambda)
    const [dbConfig, jwtSecretKey] = await Promise.all([
      getDbConfig(),
      getJwtSecretKey()
    ]);

    // Consultar cliente no banco
    const cliente = await buscarClientePorCpf(cpfLimpo, dbConfig);

    // Gerar JWT
    const { token, expiresIn } = gerarToken(cliente, jwtSecretKey);

    return resposta(200, { token, expiresIn });

  } catch (err) {
    console.error(`[${err.name}] ${err.message}`);

    const statusCode = err.statusCode || 500;
    const message = statusCode === 500 ? 'Erro interno' : err.message;

    return resposta(statusCode, { error: message });
  }
};
