export type RuntimeConfig = {
  appEnv: 'development' | 'staging' | 'production'
  version: string
  allowIndexing: boolean
}

declare global {
  interface Window {
    __DOC_MOTOR_CONFIG__?: RuntimeConfig
  }
}

export {}
