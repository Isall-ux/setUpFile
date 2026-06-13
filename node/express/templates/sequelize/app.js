import express from "express"
import { connectDB } from "./config/db.js"

const app = express()
app.use(express.json())

connectDB()

app.get("/", (req, res) => res.json({ message: "Server is running" }))

export default app
