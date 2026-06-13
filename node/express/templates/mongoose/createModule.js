import fs from "fs"
import path from "path"

const name = process.argv[2]
const type = process.argv[3] || "all"

if (!name) {
  console.error("Usage: npm run module <name> [controller|routes|model|service|all]")
  process.exit(1)
}

const validTypes = ["all", "controller", "routes", "model", "service"]
if (!validTypes.includes(type)) {
  console.error(`Invalid type "${type}". Use: ${validTypes.join(", ")}`)
  process.exit(1)
}

const cap = name.charAt(0).toUpperCase() + name.slice(1)
const featureDir = path.join(process.cwd(), "src", "features", name)
if (!fs.existsSync(featureDir)) fs.mkdirSync(featureDir, { recursive: true })

const modelContent = `import mongoose from "mongoose"

const ${name}Schema = new mongoose.Schema(
  {
    // name: { type: String, required: true },
  },
  { timestamps: true }
)

const ${cap} = mongoose.model("${cap}", ${name}Schema)
export default ${cap}`

const serviceContent = `import ${cap} from "./${name}.model.js"

export const getAll${cap} = async () => {
  return await ${cap}.find()
}

export const get${cap}ById = async (id) => {
  return await ${cap}.findById(id)
}

export const create${cap} = async (data) => {
  return await ${cap}.create(data)
}

export const update${cap} = async (id, data) => {
  return await ${cap}.findByIdAndUpdate(id, data, { new: true, runValidators: true })
}

export const delete${cap} = async (id) => {
  return await ${cap}.findByIdAndDelete(id)
}`

const controllerContent = `import * as ${name}Service from "./${name}.service.js"

export const getAll${cap} = async (req, res) => {
  try {
    const items = await ${name}Service.getAll${cap}()
    res.json(items)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const get${cap}ById = async (req, res) => {
  try {
    const item = await ${name}Service.get${cap}ById(req.params.id)
    if (!item) return res.status(404).json({ error: "${cap} not found" })
    res.json(item)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}

export const create${cap} = async (req, res) => {
  try {
    const item = await ${name}Service.create${cap}(req.body)
    res.status(201).json(item)
  } catch (err) {
    res.status(400).json({ error: err.message })
  }
}

export const update${cap} = async (req, res) => {
  try {
    const item = await ${name}Service.update${cap}(req.params.id, req.body)
    if (!item) return res.status(404).json({ error: "${cap} not found" })
    res.json(item)
  } catch (err) {
    res.status(400).json({ error: err.message })
  }
}

export const delete${cap} = async (req, res) => {
  try {
    const item = await ${name}Service.delete${cap}(req.params.id)
    if (!item) return res.status(404).json({ error: "${cap} not found" })
    res.status(204).send()
  } catch (err) {
    res.status(400).json({ error: err.message })
  }
}`

const routeContent = `import express from "express"
import {
  getAll${cap},
  get${cap}ById,
  create${cap},
  update${cap},
  delete${cap},
} from "./${name}.controller.js"

const router = express.Router()
router.get("/", getAll${cap})
router.get("/:id", get${cap}ById)
router.post("/", create${cap})
router.put("/:id", update${cap})
router.delete("/:id", delete${cap})
export default router`

const write = (fileName, content) => {
  const filePath = path.join(featureDir, fileName)
  if (fs.existsSync(filePath)) { console.log(`  Skipped (exists): ${fileName}`); return }
  fs.writeFileSync(filePath, content)
  console.log(`  Created: ${fileName}`)
}

if (type === "all" || type === "model")      write(`${name}.model.js`,      modelContent)
if (type === "all" || type === "service")    write(`${name}.service.js`,    serviceContent)
if (type === "all" || type === "controller") write(`${name}.controller.js`, controllerContent)
if (type === "all" || type === "routes")     write(`${name}.routes.js`,     routeContent)

console.log(`\n✓ Module "${name}" ready! Mount it in app.js:`)
console.log(`  import ${name}Router from "./features/${name}/${name}.routes.js"`)
console.log(`  app.use("/${name}", ${name}Router)`)
