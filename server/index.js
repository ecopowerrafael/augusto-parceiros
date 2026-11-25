/* global console */
import express from 'express'
import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { config } from './config.js'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const app = express()
const dist = path.resolve(__dirname, '../dist')
const indexFile = path.join(dist, 'index.html')

app.disable('x-powered-by')
app.use((_request, response, next) => {
  if (!config.allowIndexing) response.setHeader('X-Robots-Tag', 'noindex, nofollow')
  response.setHeader('X-Content-Type-Options', 'nosniff')
  response.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin')
  response.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()')
  response.setHeader('X-Frame-Options', 'SAMEORIGIN')
  next()
})

app.get('/api/health', (_request, response) => response.json({
  status: 'ok',
  environment: config.appEnv,
  version: config.version,
}))

app.get('/api/runtime-config', (_request, response) => response.json({
  appEnv: config.appEnv,
  version: config.version,
  allowIndexing: config.allowIndexing,
}))

app.get('/robots.txt', (_request, response) => {
  response.type('text/plain').send(config.allowIndexing
    ? 'User-agent: *\nAllow: /\nSitemap: /sitemap.xml\n'
    : 'User-agent: *\nDisallow: /\n')
})

app.get('/manifest.webmanifest', async (_request, response, next) => {
  try {
    const manifest = await fs.readFile(path.join(dist, 'manifest.json'), 'utf8')
    response.type('application/manifest+json').send(manifest)
  } catch (error) {
    next(error)
  }
})

app.use(express.static(dist, { index: false }))

app.get('*', async (_request, response, next) => {
  try {
    const html = await fs.readFile(indexFile, 'utf8')
    const robots = config.allowIndexing ? 'index, follow' : 'noindex, nofollow'
    const runtimeConfig = JSON.stringify({ appEnv: config.appEnv, version: config.version, allowIndexing: config.allowIndexing })
    const document = html
      .replace('</head>', `<meta name="robots" content="${robots}" />\n</head>`)
      .replace('<body>', `<body><script>window.__DOC_MOTOR_CONFIG__=${runtimeConfig}</script>`)
    response.type('html').send(document)
  } catch (error) {
    next(error)
  }
})

app.listen(config.port, '0.0.0.0', () => console.log(`Doc Motor listening on port ${config.port}`))
