import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import dotenv from "dotenv";
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_PATH = path.join(__dirname, "data", "vision_career_phase1_phase2_master_dataset_rebuilt.json");

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const GEMINI_KEY = process.env.GEMINI_API_KEY;

if (!GEMINI_KEY) {
  console.error("❌ GEMINI_API_KEY is missing");
}

const GEMINI_URL =
  `https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=${GEMINI_KEY}`;

// ─────────────────────────────────────────────
// Helper: extract first valid JSON object from text
// ─────────────────────────────────────────────
function extractJson(text) {
  if (!text) return null;

  // strip markdown fences
  let cleaned = text
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();

  // try direct parse first
  try {
    return JSON.parse(cleaned);
  } catch {
    // fall back to extracting the outermost { ... } block
    const start = cleaned.indexOf("{");
    const end = cleaned.lastIndexOf("}");
    if (start !== -1 && end !== -1 && end > start) {
      try {
        return JSON.parse(cleaned.substring(start, end + 1));
      } catch {
        return null;
      }
    }
    return null;
  }
}

// ─────────────────────────────────────────────
// POST /recommend
// ─────────────────────────────────────────────
app.post("/recommend", async (req, res) => {
  try {
    const promptText = req.body.prompt
      ? req.body.prompt
      : JSON.stringify(req.body);

    const geminiBody = {
      contents: [
        {
          parts: [{ text: promptText }],
        },
      ],
      generationConfig: {
        temperature: 0.4,
        topP: 0.9,
      },
    };

    const geminiRes = await fetch(GEMINI_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(geminiBody),
    });

    const geminiData = await geminiRes.json();

    if (!geminiRes.ok) {
      console.error("❌ Gemini API failure:", JSON.stringify(geminiData));
      return res.status(502).json({
        success: false,
        error: "Gemini API error",
        details: geminiData,
      });
    }

    const text =
      geminiData?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

    const parsed = extractJson(text);

    if (!parsed) {
      console.error("❌ JSON parsing failure. Raw text:", text);
      return res.status(422).json({
        success: false,
        error: "Invalid JSON from AI",
        raw: text,
      });
    }

    return res.json({ success: true, data: parsed });

  } catch (error) {
    console.error("❌ Server error:", error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

// ─────────────────────────────────────────────
// Helper: load app data from disk
// ─────────────────────────────────────────────
async function loadAppData() {
  const raw = await fs.readFile(DATA_PATH, "utf-8");
  return JSON.parse(raw);
}

// ─────────────────────────────────────────────
// GET /data
// ─────────────────────────────────────────────
app.get("/data", async (_req, res) => {
  try {
    const data = await loadAppData();
    return res.json({ success: true, data });
  } catch (error) {
    console.error("❌ Failed to load data:", error);
    return res.status(500).json({ success: false, error: "Failed to load data" });
  }
});

// ─────────────────────────────────────────────
// Health check
// ─────────────────────────────────────────────
app.get("/", (_req, res) => {
  res.send("Backend is running 🚀");
});

// ─────────────────────────────────────────────
// Start
// ─────────────────────────────────────────────
const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
