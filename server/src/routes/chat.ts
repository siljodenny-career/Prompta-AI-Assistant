import { Router } from "express";
import { sendChatCompletion, streamChatCompletion } from "../services/openrouter";

const router = Router();

// Normal response
router.post("/", async (req, res) => {
  try {
    const data = await sendChatCompletion(req.body.messages);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Streaming response
router.post("/stream", streamChatCompletion);

export default router;

