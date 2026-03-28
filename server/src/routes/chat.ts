import { Router } from "express";
import { sendChatCompletion, streamChatCompletion } from "../services/openrouter";

const router = Router();

function validateMessages(messages: unknown): messages is Array<{ role: string; content: string }> {
  if (!Array.isArray(messages) || messages.length === 0) return false;
  return messages.every(
    (msg) =>
      typeof msg === "object" &&
      msg !== null &&
      typeof msg.role === "string" &&
      ["user", "assistant", "system"].includes(msg.role) &&
      typeof msg.content === "string" &&
      msg.content.length > 0 &&
      msg.content.length <= 10000
  );
}

// Normal response
router.post("/", async (req, res) => {
  try {
    if (!validateMessages(req.body.messages)) {
      res.status(400).json({ error: "Invalid or missing messages." });
      return;
    }
    const data = await sendChatCompletion(req.body.messages);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: "An error occurred processing your request." });
  }
});

// Streaming response
router.post("/stream", (req, res) => {
  if (!validateMessages(req.body.messages)) {
    res.status(400).json({ error: "Invalid or missing messages." });
    return;
  }
  streamChatCompletion(req, res);
});

export default router;

