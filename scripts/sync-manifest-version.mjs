/* global URL */
import fs from 'node:fs/promises'
import packageJson from '../package.json' with { type: 'json' }

const manifestPath = new URL('../public/manifest.json', import.meta.url)
const manifest = JSON.parse(await fs.readFile(manifestPath, 'utf8'))
manifest.version = packageJson.version
await fs.writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`)
