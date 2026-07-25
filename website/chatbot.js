// ── CONFIG ──────────────────────────────────────────────────────────────────
// Replace with your API Gateway invoke URL after deploying the Lambda function.
// e.g. "https://abc123.execute-api.us-east-1.amazonaws.com/prod/chat"
const CHAT_API_URL = "https://apni255bk8.execute-api.us-east-1.amazonaws.com/prod/chat";
// ────────────────────────────────────────────────────────────────────────────

const sessionId = "session-" + Math.random().toString(36).slice(2);

const toggle   = document.getElementById("chat-toggle");
const window_  = document.getElementById("chat-window");
const closeBtn = document.getElementById("chat-close");
const messages = document.getElementById("chat-messages");
const input    = document.getElementById("chat-input");
const sendBtn  = document.getElementById("chat-send");

toggle.addEventListener("click", () => window_.classList.toggle("hidden"));
closeBtn.addEventListener("click", () => window_.classList.add("hidden"));

function addMsg(text, role) {
  const div = document.createElement("div");
  div.className = "msg " + role;
  div.textContent = text;
  messages.appendChild(div);
  messages.scrollTop = messages.scrollHeight;
  return div;
}

async function sendMessage() {
  const text = input.value.trim();
  if (!text) return;
  input.value = "";
  addMsg(text, "user");

  const typing = addMsg("Thinking…", "bot typing");

  try {
    const res = await fetch(CHAT_API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: text, session_id: sessionId }),
    });
    const data = await res.json();
    typing.remove();
    addMsg(data.response || "Sorry, I couldn't get a response.", "bot");
  } catch {
    typing.remove();
    addMsg("Connection error. Please try again.", "bot");
  }
}

sendBtn.addEventListener("click", sendMessage);
input.addEventListener("keydown", e => { if (e.key === "Enter") sendMessage(); });

// Greeting on first open
let greeted = false;
toggle.addEventListener("click", () => {
  if (!greeted && !window_.classList.contains("hidden")) {
    greeted = true;
    addMsg("Hi! 👋 Ask me anything about our products — availability, features, pricing, and more.", "bot");
  }
});
