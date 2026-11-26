import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { readFileSync } from 'node:fs'

const officialLogoBase64 = readFileSync(new URL('./public/assets/brand/doc-motor-logo-retangular.png', import.meta.url)).toString('base64')

export default defineConfig({ define: { __DOC_MOTOR_LOGO_BASE64__: JSON.stringify(officialLogoBase64) }, plugins: [react()] })
