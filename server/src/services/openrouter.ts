
import type { Request, Response } from "express";
import axios from "axios";
import { json } from "node:stream/consumers";

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";

export async function sendChatCompletion(messages: any[]) {
  try {
    const response = await axios.post(
      OPENROUTER_URL,
      {
        model: "openai/gpt-4o-mini",
        messages
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
          "HTTP-Referer": "http://localhost:3000",
          "X-Title": "ChatGPT Clone"
        }
      }
    );

    return response.data;
  } catch (error: any) {
    throw error.response?.data || error.message;
  }
}



export async function streamChatCompletion(req: Request, res: Response) {
  try {
    const streamResponse = await axios.post(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        model: "openai/gpt-4o-mini",
        messages: req.body.messages,
        stream: true
      },
      {
        responseType: "stream",
        headers: {
          Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
          "HTTP-Referer": "http://localhost:3000",
          "X-Title": "ChatGPT Clone"
        }
      }
    );

    res.setHeader("Content-Type", "text/event-stream");

    for await (const chunk of streamResponse.data) {
      const lines = chunk
        .toString()
        .split("\n")
        .filter((line: string) => line.trim() !== "");

      for (const line of lines) {
        if (line.startsWith("data: ")) {
          const jsonStr = line.substring(6).trim(); // Safely remove 'data: ' and trim whitespace

          if (jsonStr === "[DONE]") {
            res.end();
            return;
          }

          try {
            const parsed = JSON.parse(jsonStr);
            const content = parsed.choices?.[0]?.delta?.content || "";

            if (content) {
              res.write(`data: ${JSON.stringify(content)}\n\n`);
            }
          } catch (e: any) {
            console.error("Failed to parse OpenRouter chunk:", jsonStr, e.message);
            // Ignore incomplete chunks instead of crashing the server
          }
        }
      }
    }

    res.end();

  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}
