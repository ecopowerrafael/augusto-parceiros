/* global process, console */
import express from 'express'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const app = express()
const port = Number(process.env.PORT || 3000)
const dist = path.resolve(__dirname, '../dist')

app.disable('x-powered-by')
app.use(express.static(dist, { index: 'index.html' }))
app.get('*', (_request, response) => response.sendFile(path.join(dist, 'index.html')))
app.listen(port, '0.0.0.0', () => console.log(`Doc Motor listening on port ${port}`))
