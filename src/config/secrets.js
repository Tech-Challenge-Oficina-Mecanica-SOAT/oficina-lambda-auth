const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');
const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');
const { ConfiguracaoError } = require('../errors');

const region = process.env.AWS_REGION || 'us-east-1';
const env = process.env.ENVIRONMENT || 'homolog';

const smClient = new SecretsManagerClient({ region });
const ssmClient = new SSMClient({ region });

// Cache em memória para evitar chamadas repetidas (Lambda warm)
const cache = {};

async function getSecret(secretName) {
  if (cache[secretName]) return cache[secretName];

  try {
    const response = await smClient.send(
      new GetSecretValueCommand({ SecretId: secretName })
    );
    const value = response.SecretString;
    cache[secretName] = value;
    return value;
  } catch (err) {
    console.error(`Erro ao buscar secret ${secretName}:`, err.message);
    throw new ConfiguracaoError(`Não foi possível obter o secret: ${secretName}`);
  }
}

async function getParameter(paramName) {
  if (cache[paramName]) return cache[paramName];

  try {
    const response = await ssmClient.send(
      new GetParameterCommand({ Name: paramName, WithDecryption: true })
    );
    const value = response.Parameter.Value;
    cache[paramName] = value;
    return value;
  } catch (err) {
    console.error(`Erro ao buscar parâmetro ${paramName}:`, err.message);
    throw new ConfiguracaoError(`Não foi possível obter o parâmetro: ${paramName}`);
  }
}

async function getDbConfig() {
  const [endpoint, port, dbName, username, password] = await Promise.all([
    getParameter(`/oficina/${env}/db/endpoint`),
    getParameter(`/oficina/${env}/db/port`),
    getParameter(`/oficina/${env}/db/name`),
    getParameter(`/oficina/${env}/db/username`),
    getSecret(`oficina/${env}/db-password`)
  ]);

  return { endpoint, port: parseInt(port, 10), dbName, username, password };
}

async function getJwtSecretKey() {
  return getSecret(`oficina/${env}/jwt-secret-key`);
}

module.exports = { getDbConfig, getJwtSecretKey };
