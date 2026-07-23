#!/usr/bin/env python3
"""Minimal Kling AI generation client (official api.klingai.com, single Bearer token).

Key lives OUTSIDE the workspace at ~/.secrets/kling.json (never committed).
Usage:
  python kling_gen.py video "a golden retriever surfing a wave, cinematic"          [--duration 5 --aspect 16:9 --mode std --model kling-v1]
  python kling_gen.py image "a watercolor logo of a tree, minimal"                  [--aspect 1:1 --n 1 --model kling-v1]
Outputs land in kling/outputs/. First real run confirms model_name/params (easy to tweak).
"""
import json, sys, time, os, urllib.request, urllib.error, argparse, datetime

SECRET = os.path.expanduser("~/.secrets/kling.json")
OUTDIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "outputs")

def cfg():
    c = json.load(open(SECRET))
    return c["base_url"].rstrip("/"), c["api_key"]

def _req(method, url, key, body=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(url, data=data, method=method,
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(r, timeout=60) as resp:
            return resp.status, json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        try: return e.code, json.loads(e.read().decode())
        except Exception: return e.code, {"raw": str(e)}

def _poll(base, key, path, task_id, kind):
    print(f"submitted task {task_id}; polling...", flush=True)
    for _ in range(120):  # up to ~10 min
        code, j = _req("GET", f"{base}{path}/{task_id}", key)
        st = (j.get("data") or {}).get("task_status") or j.get("message")
        if st in ("succeed", "completed"):
            res = (j.get("data") or {}).get("task_result") or {}
            items = res.get("videos") or res.get("images") or []
            return [it.get("url") for it in items if it.get("url")]
        if st in ("failed", "error"):
            raise RuntimeError(f"generation failed: {json.dumps(j)}")
        time.sleep(5)
    raise TimeoutError("timed out waiting for result")

def _download(urls, kind):
    os.makedirs(OUTDIR, exist_ok=True)
    ts = datetime.datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    saved = []
    for i, u in enumerate(urls):
        ext = "mp4" if kind == "video" else "png"
        p = os.path.join(OUTDIR, f"kling-{kind}-{ts}-{i}.{ext}")
        urllib.request.urlretrieve(u, p); saved.append(p)
    return saved

def gen_video(a):
    base, key = cfg()
    body = {"model_name": a.model, "prompt": a.prompt, "duration": str(a.duration),
            "aspect_ratio": a.aspect, "mode": a.mode}
    code, j = _req("POST", f"{base}/v1/videos/text2video", key, body)
    print("create:", code, json.dumps(j)[:300], flush=True)
    tid = (j.get("data") or {}).get("task_id")
    if not tid: sys.exit("no task_id returned (check credits/params above)")
    urls = _poll(base, key, "/v1/videos/text2video", tid, "video")
    print("DONE:", _download(urls, "video"))

def gen_image(a):
    base, key = cfg()
    body = {"model_name": a.model, "prompt": a.prompt, "n": a.n, "aspect_ratio": a.aspect}
    code, j = _req("POST", f"{base}/v1/images/generations", key, body)
    print("create:", code, json.dumps(j)[:300], flush=True)
    tid = (j.get("data") or {}).get("task_id")
    if not tid: sys.exit("no task_id returned (check credits/params above)")
    urls = _poll(base, key, "/v1/images/generations", tid, "image")
    print("DONE:", _download(urls, "image"))

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    v = sub.add_parser("video"); v.add_argument("prompt"); v.add_argument("--duration", default=5)
    v.add_argument("--aspect", default="16:9"); v.add_argument("--mode", default="std"); v.add_argument("--model", default="kling-v1")
    im = sub.add_parser("image"); im.add_argument("prompt"); im.add_argument("--n", type=int, default=1)
    im.add_argument("--aspect", default="1:1"); im.add_argument("--model", default="kling-v1")
    a = p.parse_args()
    (gen_video if a.cmd == "video" else gen_image)(a)
