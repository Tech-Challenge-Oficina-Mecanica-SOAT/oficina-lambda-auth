function validarCpf(cpf) {
  const digits = String(cpf).replace(/\D/g, '');

  if (digits.length !== 11) return false;
  if (/^(\d)\1+$/.test(digits)) return false; // 111.111.111-11 etc

  const calc = (base, factor) => {
    let sum = 0;
    for (let i = 0; i < base.length; i++) {
      sum += parseInt(base[i], 10) * (factor - i);
    }
    const rest = (sum * 10) % 11;
    return rest === 10 ? 0 : rest;
  };

  const d1 = calc(digits.slice(0, 9), 10);
  if (d1 !== parseInt(digits[9], 10)) return false;

  const d2 = calc(digits.slice(0, 10), 11);
  if (d2 !== parseInt(digits[10], 10)) return false;

  return true;
}

module.exports = { validarCpf };
