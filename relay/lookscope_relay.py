import base64
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib import error, request


HOST = "0.0.0.0"
PORT = 8787


def load_config():
    config_path = os.path.join(os.path.dirname(__file__), "server_config.json")
    if not os.path.exists(config_path):
        return {}

    with open(config_path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def build_prompt():
    return """
You are a premium appearance analysis assistant for a private iPhone app.
Review all provided photos together as one person. Do not guess protected traits, health issues, ethnicity, religion, sexuality, disability, or exact age.
Focus on camera presentation, visual harmony, grooming, style potential, and image quality.
Return JSON only with this exact schema:
{
  "overallScore": number,
  "summaryLabel": string,
  "scoreContext": string,
  "strengths": [string],
  "categoryScores": [{"category": string, "score": number, "note": string}],
  "suggestions": [{"title": string, "reason": string}]
}
Keep it concise, premium, and useful.
""".strip()


class RelayHandler(BaseHTTPRequestHandler):
    def _send_json(self, status_code, payload):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.end_headers()

    def do_GET(self):
        if self.path == "/health":
            self._send_json(200, {"ok": True})
            return

        self._send_json(404, {"error": "Not found"})

    def do_POST(self):
        if self.path != "/analyze":
            self._send_json(404, {"error": "Not found"})
            return

        try:
            content_length = int(self.headers.get("Content-Length", "0"))
            raw = self.rfile.read(content_length)
            payload = json.loads(raw.decode("utf-8"))
        except Exception:
            self._send_json(400, {"error": "Invalid JSON body."})
            return

        config = load_config()
        api_key = config.get("gemini_api_key") or os.environ.get("GEMINI_API_KEY", "")
        project_id = config.get("google_project_id") or os.environ.get("GOOGLE_PROJECT_ID", "")
        model = payload.get("model") or config.get("model") or "gemini-2.5-flash"
        photos = payload.get("photos") or []

        if not api_key:
            self._send_json(500, {"error": "Gemini API key is missing on the relay server."})
            return

        if not photos:
            self._send_json(400, {"error": "No photos were provided."})
            return

        parts = [{"text": build_prompt()}]
        for photo in photos:
            jpeg_base64 = photo.get("jpegBase64", "")
            if not jpeg_base64:
                continue
            try:
                base64.b64decode(jpeg_base64, validate=True)
            except Exception:
                self._send_json(400, {"error": "One of the photos has invalid base64 data."})
                return

            parts.append(
                {
                    "inline_data": {
                        "mime_type": "image/jpeg",
                        "data": jpeg_base64,
                    }
                }
            )

        gemini_body = json.dumps(
            {
                "contents": [{"parts": parts}],
                "generationConfig": {"responseMimeType": "application/json"},
            }
        ).encode("utf-8")

        gemini_request = request.Request(
            url=f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent",
            data=gemini_body,
            headers={
                "Content-Type": "application/json",
                "x-goog-api-key": api_key,
            },
            method="POST",
        )

        try:
            with request.urlopen(gemini_request, timeout=180) as response:
                gemini_raw = response.read()
        except error.HTTPError as exc:
            details = exc.read().decode("utf-8", errors="replace")
            self._send_json(502, {"error": f"Gemini HTTP error: {details}"})
            return
        except Exception as exc:
            self._send_json(502, {"error": f"Gemini connection failed: {exc}"})
            return

        try:
            gemini_payload = json.loads(gemini_raw.decode("utf-8"))
            text = gemini_payload["candidates"][0]["content"]["parts"][0]["text"]
            final_payload = json.loads(text)
        except Exception:
            self._send_json(502, {"error": "Gemini returned an unexpected payload."})
            return

        if project_id:
            final_payload["scoreContext"] = (
                f'{final_payload.get("scoreContext", "")} '
                f"Processed through your private PC relay ({project_id})."
            ).strip()

        self._send_json(200, final_payload)


if __name__ == "__main__":
    print(f"Lookscope relay server running on http://{HOST}:{PORT}")
    ThreadingHTTPServer((HOST, PORT), RelayHandler).serve_forever()
