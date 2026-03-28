import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import rateLimit from "express-rate-limit";
import chatRoutes from "./routes/chat";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

const allowedOrigins = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(",")
  : ["http://localhost:3000", "https://prompta-ai-demo.web.app"];

app.use(cors({ origin: allowedOrigins }));
app.use(express.json({ limit: "1mb" }));

const chatLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  message: { error: "Too many requests, please try again later." },
});

app.use("/api/chat", chatLimiter, chatRoutes);

app.get("/", (req, res) => {
  res.send("Prompta AI Server Running");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
