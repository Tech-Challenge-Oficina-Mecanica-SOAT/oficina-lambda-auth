class CpfInvalidoError extends Error {
  constructor(message = 'CPF inválido') {
    super(message);
    this.name = 'CpfInvalidoError';
    this.statusCode = 400;
  }
}

class ClienteNaoEncontradoError extends Error {
  constructor(message = 'Cliente não encontrado') {
    super(message);
    this.name = 'ClienteNaoEncontradoError';
    this.statusCode = 404;
  }
}

class ClienteInativoError extends Error {
  constructor(message = 'Cliente inativo') {
    super(message);
    this.name = 'ClienteInativoError';
    this.statusCode = 403;
  }
}

class ConfiguracaoError extends Error {
  constructor(message = 'Erro de configuração interna') {
    super(message);
    this.name = 'ConfiguracaoError';
    this.statusCode = 500;
  }
}

module.exports = {
  CpfInvalidoError,
  ClienteNaoEncontradoError,
  ClienteInativoError,
  ConfiguracaoError
};
