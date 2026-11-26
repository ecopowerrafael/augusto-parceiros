const messages: Record<string, string> = {
  DOCUMENT_TYPE_MISMATCH: 'O documento informado não corresponde ao tipo de pessoa selecionado.',
  INVALID_DOCUMENT: 'Informe um CPF ou CNPJ válido.',
  INVALID_CPF: 'O CPF informado é inválido. Confira os números digitados.',
  INVALID_CNPJ: 'O CNPJ informado é inválido. Confira os dados digitados.',
  REGISTRATION_CONFLICT: 'Já existe uma conta ou documento cadastrado. Tente entrar ou confira os dados.',
  INVALID_CREDENTIALS: 'E-mail ou senha incorretos.',
  AUTHENTICATION_REQUIRED: 'Entre na sua conta para continuar.',
  FORBIDDEN: 'Você não possui permissão para realizar esta operação.',
  ACCOUNT_NOT_ACTIVE: 'Seu cadastro ainda não está ativo para acessar esta função.',
  PASSWORD_RECOVERY_NOT_CONFIGURED: 'A recuperação de senha está temporariamente indisponível. Entre em contato com nossa equipe.',
  CURRENT_PASSWORD_INVALID: 'A senha atual informada está incorreta.',
  RESET_TOKEN_INVALID: 'O link de redefinição é inválido ou expirou.',
  TOO_MANY_REQUESTS: 'Você realizou muitas tentativas. Aguarde alguns instantes e tente novamente.',
  RATE_LIMIT_EXCEEDED: 'Você realizou muitas tentativas. Aguarde alguns instantes e tente novamente.',
  DATABASE_NOT_CONFIGURED: 'Não foi possível conectar ao serviço. Tente novamente em instantes.',
  DATABASE_NOT_READY: 'Não foi possível concluir a operação. Tente novamente em instantes.',
  INTERNAL_ERROR: 'Não foi possível concluir a operação. Tente novamente em instantes.',
  NETWORK_ERROR: 'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.',
  PARTNER_COMPANY_NOT_FOUND: 'Não encontramos uma empresa vinculada a esta conta.',
  PARTNER_NOT_FOUND: 'O cadastro do parceiro não foi encontrado.',
  INVALID_STATUS: 'A alteração de status solicitada não é válida.',
  COLLABORATOR_MANAGEMENT_FORBIDDEN: 'Somente o responsável da empresa pode gerenciar colaboradores.',
  INVALID_SIMULATION_INPUT: 'Confira as placas, combustíveis e cilindradas informados.',
  INVALID_PLATE: 'Informe uma placa válida no padrão antigo ou Mercosul.',
  INVALID_FUEL: 'Selecione um combustível válido.',
  INVALID_CYLINDER: 'Informe uma cilindrada positiva em litros ou cm³.',
}

export function friendlyApiMessage(code: unknown, status?: number) {
  const normalized = String(code || '')
  if (messages[normalized]) return messages[normalized]
  if (status === 429) return messages.TOO_MANY_REQUESTS
  if (status === 401) return messages.AUTHENTICATION_REQUIRED
  if (status === 403) return messages.FORBIDDEN
  if ((status || 0) >= 500) return messages.INTERNAL_ERROR
  return 'Não foi possível concluir a operação. Confira os dados e tente novamente.'
}

export function friendlyValidationMessages(fields: unknown) {
  if (!Array.isArray(fields)) return ''
  return fields.map((field) => typeof field === 'object' && field !== null && 'message' in field ? String(field.message) : '').filter(Boolean).join(' ')
}

const simulationFieldLabels: Record<string, string> = {
  'vehicle_target.fuel': 'Combustível original',
  'vehicle_donor.fuel': 'Combustível do motor',
  'vehicle_target.plate': 'Placa de destino',
  'vehicle_donor.plate': 'Placa de origem',
  'vehicle_target.engine_cc': 'Cilindrada original',
  'vehicle_donor.engine_cc': 'Cilindrada do motor',
}

export function friendlyApiDetails(code: unknown, details: unknown) {
  if (!Array.isArray(details) || details.length === 0) return ''
  if (String(code) === 'INVALID_SERVICE_CONFIGURATION') return `Configuração inválida: ${details.filter((detail) => typeof detail === 'string').join(' ')}`
  if (String(code) === 'INVALID_SIMULATION_INPUT') {
    const messages = details.map((detail) => {
      if (!detail || typeof detail !== 'object') return ''
      const field = 'field' in detail ? String(detail.field) : ''
      const message = 'message' in detail ? String(detail.message) : ''
      return message ? `${simulationFieldLabels[field] || field}: ${message}` : ''
    }).filter(Boolean)
    return messages.length ? `Dados inválidos no simulador: ${messages.join(' ')}` : ''
  }
  return ''
}
