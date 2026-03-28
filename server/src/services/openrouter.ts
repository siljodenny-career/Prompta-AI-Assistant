import type { Request, Response } from "express";
import axios from "axios";

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";
const REQUEST_TIMEOUT = 30000;

const siteUrl = process.env.SITE_URL || "https://prompta-ai-demo.web.app";

export async function sendChatCompletion(messages: Array<{ role: string; content: string }>) {
  try {
    const response = await axios.post(
      OPENROUTER_URL,
      {
        model: "openai/gpt-4o-mini",
        messages
      },
      {
        timeout: REQUEST_TIMEOUT,
        headers: {
          Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
          "HTTP-Referer": siteUrl,
          "X-Title": "Prompta AI"
        }
      }
    );

    return response.data;
  } catch (error: any) {
    throw new Error("Failed to get AI response.");
  }
}

export async function streamChatCompletion(req: Request, res: Response) {
  try {
    const streamResponse = await axios.post(
      OPENROUTER_URL,
      {
        model: "openai/gpt-4o-mini",
        messages: req.body.messages,
        stream: true
      },
      {
        responseType: "stream",
        timeout: REQUEST_TIMEOUT,
        headers: {
          Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
          "HTTP-Referer": siteUrl,
          "X-Title": "Prompta AI"
        }
      }
    );

    res.setHeader("Content-Type", "text/event-stream");

    req.on("close", () => {
      streamResponse.data.destroy();
    });

    for await (const chunk of streamResponse.data) {
      const lines = chunk
        .toString()
        .split("\n")
        .filter((line: string) => line.trim() !== "");

      for (const line of lines) {
        if (line.startsWith("data: ")) {
          const jsonStr = line.substring(6).trim();

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
          } catch {
            // Ignore incomplete chunks
          }
        }
      }
    }

    res.end();

  } catch (error: any) {
    if (!res.headersSent) {
      res.status(500).json({ error: "An error occurred processing your request." });
    }
  }
}
