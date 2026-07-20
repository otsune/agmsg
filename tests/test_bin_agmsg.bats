#!/usr/bin/env bats

BIN="$BATS_TEST_DIRNAME/../bin/agmsg.js"

@test "bin/agmsg.js: --version exits successfully" {
  run node "$BIN" --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "agmsg bootstrapper" ]]
}

@test "bin/agmsg.js: --help exits successfully" {
  run node "$BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "npm bootstrapper for cross-agent messaging" ]]
}

@test "bin/agmsg.js: toBashPath converts backslashes to forward slashes (#262)" {
  run node -e 'const { toBashPath } = require(process.argv[1]); const input = String.raw`C:\Users\me\AppData\Local\Temp\agmsg-bootstrap-abc123\setup.sh`; const expected = "C:/Users/me/AppData/Local/Temp/agmsg-bootstrap-abc123/setup.sh"; if (toBashPath(input) !== expected) process.exit(1);' "$BIN"
  [ "$status" -eq 0 ]
}

@test "bin/agmsg.js: toBashPath is a no-op on POSIX paths" {
  run node -e 'const { toBashPath } = require(process.argv[1]); const p = "/tmp/agmsg-bootstrap-abc123/setup.sh"; if (toBashPath(p) !== p) process.exit(1);' "$BIN"
  [ "$status" -eq 0 ]
}

@test "bin/agmsg.js: resolveBash prefers Git Bash over PATH bash on Windows" {
  run node -e 'const { resolveBash } = require(process.argv[1]); const env = { ProgramFiles: String.raw`C:\Program Files` }; const expected = String.raw`C:\Program Files\Git\bin\bash.exe`; const actual = resolveBash("win32", env, p => p === expected); if (actual !== expected) process.exit(1);' "$BIN"
  [ "$status" -eq 0 ]
}

@test "bin/agmsg.js: resolveBash honors GIT_BASH on Windows" {
  run node -e 'const { resolveBash } = require(process.argv[1]); const expected = String.raw`D:\Git\bin\bash.exe`; const actual = resolveBash("win32", { GIT_BASH: expected }, p => p === expected); if (actual !== expected) process.exit(1);' "$BIN"
  [ "$status" -eq 0 ]
}
