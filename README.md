# Oura Insights — AI Coding Comparison

A personal health analytics app built in parallel by different AI coding tools, starting from the same spec.

## Purpose

This repo is a benchmark: the same `spec.md` is given to multiple AI tools independently. Each tool builds the full app on its own branch. The goal is to compare quality, architecture decisions, and completeness across AI coding assistants.

## Branch structure

| Branch | AI Tool | Status |
|--------|---------|--------|
| `main` | — | Spec only (this branch, locked) |
| `windsurf` | Windsurf | Phase 0 complete |
| `claude` | Claude Code | Phase 0 + test fixes |
| `codex` | Codex | Phase 0 complete |

## How to compare

```bash
# See what Claude did differently from Windsurf
git diff windsurf..claude

# See all files changed by Claude vs the baseline
git diff main..claude --stat
```

## The spec

See [`spec.md`](./spec.md) — this is the single source of truth given to each AI tool. It is not modified per-branch; only this `main` branch holds the canonical version.

## Requirements

- macOS 14.0+ / iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Running an implementation

```bash
git checkout codex
./Scripts/generate_xcodeproj.sh
open OuraInsights.xcodeproj
```

The helper script runs `xcodegen generate` and then normalises the generated project format so it opens cleanly in the repo's current Xcode environment.

## Running tests (Swift package)

```bash
swift test
```
