import json
import os
import boto3

client = boto3.client("bedrock-agent-runtime", region_name="us-east-1")

AGENT_ID    = os.environ["AGENT_ID"]
AGENT_ALIAS = os.environ.get("AGENT_ALIAS_ID", "TSTALIASID")

CORS = {
    "Access-Control-Allow-Origin":  "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS",
}

def handler(event, context):
    method = (event.get("requestContext") or {}).get("http", {}).get("method", "")
    if method == "OPTIONS":
        return {"statusCode": 200, "headers": CORS, "body": ""}

    body       = json.loads(event.get("body") or "{}")
    user_input = body.get("message", "").strip()
    session_id = body.get("session_id", "default-session")

    if not user_input:
        return {"statusCode": 400, "headers": CORS,
                "body": json.dumps({"error": "message is required"})}

    response = client.invoke_agent(
        agentId      = AGENT_ID,
        agentAliasId = AGENT_ALIAS,
        sessionId    = session_id,
        inputText    = user_input,
    )

    # Stream the completion chunks into a single string
    reply = ""
    for event_ in response.get("completion", []):
        chunk = event_.get("chunk", {})
        reply += chunk.get("bytes", b"").decode("utf-8")

    return {
        "statusCode": 200,
        "headers": CORS,
        "body": json.dumps({"response": reply}),
    }
