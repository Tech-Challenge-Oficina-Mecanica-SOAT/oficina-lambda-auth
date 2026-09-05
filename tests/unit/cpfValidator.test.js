const { validarCpf } = require('../../src/auth/cpfValidator');

describe('validarCpf', () => {

  // ─── CPFs válidos ────────────────────────────────────────
  describe('CPFs válidos', () => {
    test('deve aceitar CPF válido sem máscara', () => {
      expect(validarCpf('12345678909')).toBe(true);
    });

    test('deve aceitar CPF válido com máscara', () => {
      expect(validarCpf('123.456.789-09')).toBe(true);
    });

    test('deve aceitar outro CPF válido', () => {
      expect(validarCpf('98765432100')).toBe(true);
    });
  });

  // ─── CPFs inválidos ──────────────────────────────────────
  describe('CPFs inválidos', () => {
    test('deve rejeitar CPF com todos os dígitos iguais (111...)', () => {
      expect(validarCpf('11111111111')).toBe(false);
    });

    test('deve rejeitar CPF com todos os dígitos iguais (000...)', () => {
      expect(validarCpf('00000000000')).toBe(false);
    });

    test('deve rejeitar CPF com dígito verificador errado', () => {
      expect(validarCpf('12345678900')).toBe(false);
    });

    test('deve rejeitar CPF com menos de 11 dígitos', () => {
      expect(validarCpf('1234567890')).toBe(false);
    });

    test('deve rejeitar CPF com mais de 11 dígitos', () => {
      expect(validarCpf('123456789012')).toBe(false);
    });

    test('deve rejeitar CPF vazio', () => {
      expect(validarCpf('')).toBe(false);
    });

    test('deve rejeitar CPF nulo', () => {
      expect(validarCpf(null)).toBe(false);
    });

    test('deve rejeitar CPF com letras', () => {
      expect(validarCpf('abc.def.ghi-jk')).toBe(false);
    });

    test('deve rejeitar CPF undefined', () => {
      expect(validarCpf(undefined)).toBe(false);
    });
  });
});
