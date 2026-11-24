#!/usr/bin/env python3
"""배포 전 자동 검사. 하나라도 실패하면 0이 아닌 값으로 끝난다.

  1. 문법: 모든 애드온 Lua 파일이 게임과 같은 Lua 5.1 문법으로 읽히는지
  2. 공용 파일: ErrorLog.lua 가 세 애드온에서 똑같은지
  3. 시나리오: 가짜 게임 환경에서 애드온을 돌린 출력이 기대 결과와 같은지

실제 게임에서의 동작까지 보장하지는 않는다. 문법 오류와, 고친 뒤 원래 되던 동작이 깨지는 것을 막는 용도.
기대 결과를 일부러 바꿨을 때:  python3 tests/run_tests.py --update
"""
import glob, os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UPDATE = "--update" in sys.argv
failed = []


def check(name, ok, detail=""):
    print(("PASS  " if ok else "FAIL  ") + name + (("\n      " + detail) if (detail and not ok) else ""))
    if not ok:
        failed.append(name)


# 1. Lua 5.1 문법
import lupa.lua51 as lua51

rt = lua51.LuaRuntime()
files = sorted(glob.glob(os.path.join(ROOT, "addons", "*", "*", "*.lua")))
check("Lua 파일을 찾음", len(files) > 0)
for f in files:
    rt.globals().SRC = open(f, encoding="utf-8").read()
    err = rt.eval("(function() local fn, e = loadstring(SRC, 'x') return e end)()")
    check("문법 " + os.path.relpath(f, ROOT), err is None, str(err))

# 2. 공용 파일이 같은지
logs = sorted(glob.glob(os.path.join(ROOT, "addons", "*", "*", "ErrorLog.lua")))
bodies = {open(f, encoding="utf-8").read() for f in logs}
check("ErrorLog.lua 세 애드온에 동일 (%d개)" % len(logs), len(logs) == 3 and len(bodies) == 1)

# 3. TOC 에 적힌 파일이 실제로 있는지
for toc in sorted(glob.glob(os.path.join(ROOT, "addons", "*", "*", "*.toc"))):
    d = os.path.dirname(toc)
    missing = [l.strip() for l in open(toc, encoding="utf-8") if l.strip() and not l.startswith("#")
               and not os.path.exists(os.path.join(d, l.strip().replace("\\", "/")))]
    check("TOC 파일 목록 " + os.path.relpath(toc, ROOT), not missing, "없는 파일: " + ", ".join(missing))

# 4. 시나리오
for script in sorted(glob.glob(os.path.join(ROOT, "tests", "scenario_*.py"))):
    name = os.path.basename(script)[len("scenario_"):-3]
    exp_path = os.path.join(ROOT, "tests", "expected", name + ".txt")
    run = subprocess.run([sys.executable, script], capture_output=True, text=True)
    out = run.stdout
    if run.returncode != 0:
        check("시나리오 " + name, False, (run.stderr or "").strip().splitlines()[-1] if run.stderr else "실행 실패")
        continue
    if UPDATE:
        open(exp_path, "w", encoding="utf-8").write(out)
        print("UPDATED " + os.path.relpath(exp_path, ROOT))
        continue
    exp = open(exp_path, encoding="utf-8").read() if os.path.exists(exp_path) else ""
    if out != exp:
        a, b = exp.splitlines(), out.splitlines()
        diff = next((i for i in range(max(len(a), len(b))) if i >= len(a) or i >= len(b) or a[i] != b[i]), 0)
        detail = "줄 %d\n      기대: %s\n      실제: %s" % (diff + 1, a[diff] if diff < len(a) else "(없음)", b[diff] if diff < len(b) else "(없음)")
        check("시나리오 " + name, False, detail)
    else:
        check("시나리오 " + name, True)

print()
print("실패 %d건" % len(failed) if failed else "모두 통과")
sys.exit(1 if failed else 0)
