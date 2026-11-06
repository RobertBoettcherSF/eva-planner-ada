#!/usr/bin/env python3
from pathlib import Path
import base64
root = Path(__file__).resolve().parent.parent
wasm = (root / "obj/wasm/eva_plan.wasm").read_bytes()
b64 = base64.b64encode(wasm).decode("ascii")
tmpl = (root / "web/template.html").read_text()
if "__WASM_BASE64__" not in tmpl:
    raise SystemExit("web/template.html missing __WASM_BASE64__ placeholder")
(root / "dist").mkdir(exist_ok=True)
import subprocess, html, json
out = subprocess.run([str(root / "bin/eva_plan_driver")], check=True,
                     capture_output=True, text=True).stdout
body = out.split("=== CONSOLE BEGIN ===\n", 1)[1].split("=== CONSOLE END ===", 1)[0]
tables = [t.strip("\n") for t in body.split("\n\n") if t.strip()]
if len(tables) != 3:
    raise SystemExit("expected 3 console tables from eva_plan_driver")
tmpl = tmpl.replace("__CONSOLE_JSON__", json.dumps(tables).replace("</", "<\\/"))
(root / "dist/index.html").write_text(tmpl.replace("__WASM_BASE64__", b64))
(root / "dist/VERSION").write_text("0.2.0\n")
print("wrote dist/index.html", (root / "dist/index.html").stat().st_size, "wasm", len(wasm))
