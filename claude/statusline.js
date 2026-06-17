#!/usr/bin/env node
// Claude Code statusline. Reads JSON from stdin, prints one line.
// Fields per spec: session_id, transcript_path, cwd, model, workspace,
// version, output_style, exceeds_200k_tokens, cost.

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const RESET = "\x1b[0m";
const DIM = "\x1b[2m";
const BOLD = "\x1b[1m";
const CYAN = "\x1b[36m";
const BLUE = "\x1b[34m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const RED = "\x1b[31m";
const MAGENTA = "\x1b[35m";
const GRAY = "\x1b[90m";

function read_stdin_sync() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch (_) {
    return "";
  }
}

function safe_json(s) {
  try {
    return JSON.parse(s);
  } catch (_) {
    return {};
  }
}

function short_path(p, home) {
  if (!p) return "";
  if (home && p.startsWith(home)) return "~" + p.slice(home.length);
  return p;
}

function fmt_tokens(n) {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(2) + "M";
  if (n >= 1000) return (n / 1000).toFixed(1) + "k";
  return String(n);
}

function fmt_duration(ms) {
  if (!ms || ms < 0) return null;
  const s = Math.floor(ms / 1000);
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  if (h > 0) return `${h}h${m}m`;
  if (m > 0) return `${m}m${sec}s`;
  return `${sec}s`;
}

function last_usage_from_transcript(transcript_path) {
  if (!transcript_path) return null;
  try {
    if (!fs.existsSync(transcript_path)) return null;
    const data = fs.readFileSync(transcript_path, "utf8");
    const lines = data.split("\n");
    for (let i = lines.length - 1; i >= 0; i--) {
      const line = lines[i].trim();
      if (!line || !line.includes('"usage"')) continue;
      const obj = safe_json(line);
      const usage = obj?.message?.usage;
      if (usage && typeof usage.input_tokens === "number") return usage;
    }
  } catch (_) {}
  return null;
}

function git_branch(cwd) {
  try {
    const out = execSync("git symbolic-ref --short HEAD 2>/dev/null", {
      cwd,
      encoding: "utf8",
      timeout: 200,
    }).trim();
    return out || null;
  } catch (_) {
    return null;
  }
}

function git_dirty(cwd) {
  try {
    const out = execSync("git status --porcelain 2>/dev/null", {
      cwd,
      encoding: "utf8",
      timeout: 200,
    });
    return out.trim().length > 0;
  } catch (_) {
    return false;
  }
}

function context_window_for(model_id) {
  // Defaults; Claude 4.x is 200k context.
  if (!model_id) return 200_000;
  if (/sonnet-4/.test(model_id)) return 200_000;
  if (/haiku-4/.test(model_id)) return 200_000;
  if (/opus-4/.test(model_id)) return 200_000;
  return 200_000;
}

function pct_color(p) {
  if (p >= 85) return RED;
  if (p >= 70) return YELLOW;
  if (p >= 50) return MAGENTA;
  return GREEN;
}

function effort_color(level) {
  switch (level) {
    case "max": return RED;
    case "high": return YELLOW;
    case "medium": return BLUE;
    case "low": return GRAY;
    default: return MAGENTA;
  }
}

const raw = read_stdin_sync();
const input = safe_json(raw);
const home = process.env.HOME || "";

const model_id = input?.model?.id || "";
const model_name = input?.model?.display_name || model_id || "model?";
const cwd = input?.cwd || input?.workspace?.current_dir || process.cwd();
const project_dir = input?.workspace?.project_dir || cwd;
const version = input?.version || "";
const output_style = input?.output_style?.name || "";
const exceeds_200k = input?.exceeds_200k_tokens === true;
const cost = input?.cost || {};

const usage = last_usage_from_transcript(input?.transcript_path);
let ctx_tokens = 0;
if (usage) {
  ctx_tokens =
    (usage.input_tokens || 0) +
    (usage.cache_creation_input_tokens || 0) +
    (usage.cache_read_input_tokens || 0);
}
const ctx_max = exceeds_200k ? 1_000_000 : context_window_for(model_id);
const ctx_pct = ctx_max ? Math.min(100, (ctx_tokens / ctx_max) * 100) : 0;

const branch = git_branch(cwd);
const dirty = branch ? git_dirty(cwd) : false;

const parts = [];

// model
parts.push(`${BOLD}${CYAN}${model_name}${RESET}`);

// thinking effort (always shown)
const thinking_on = input?.thinking?.enabled !== false;
const effort_level = input?.effort?.level;
if (!thinking_on) {
  parts.push(`${GRAY}off${RESET}`);
} else if (effort_level) {
  parts.push(`${effort_color(effort_level)}${effort_level}${RESET}`);
}

// context
if (ctx_tokens > 0) {
  const col = pct_color(ctx_pct);
  parts.push(
    `${col}${ctx_pct.toFixed(1)}%${RESET}${DIM} ctx${RESET} ${DIM}(${fmt_tokens(ctx_tokens)}/${fmt_tokens(ctx_max)})${RESET}`,
  );
} else {
  parts.push(`${DIM}-- ctx${RESET}`);
}

// output style / effort hint
if (output_style && output_style !== "default") {
  parts.push(`${MAGENTA}${output_style}${RESET}`);
}

// cwd
const cwd_short = short_path(cwd, home);
parts.push(`${BLUE}${cwd_short}${RESET}`);

// git
if (branch) {
  const mark = dirty ? `${YELLOW}*${RESET}` : "";
  parts.push(`${GREEN}${branch}${RESET}${mark}`);
}

// cost / duration / churn
const cost_usd = cost?.total_cost_usd;
if (typeof cost_usd === "number") {
  parts.push(`${DIM}$${cost_usd.toFixed(3)}${RESET}`);
}
const dur = fmt_duration(cost?.total_duration_ms);
if (dur) parts.push(`${DIM}${dur}${RESET}`);
const adds = cost?.total_lines_added || 0;
const dels = cost?.total_lines_removed || 0;
if (adds || dels) {
  parts.push(`${GREEN}+${adds}${RESET}${GRAY}/${RESET}${RED}-${dels}${RESET}`);
}

// version
if (version) parts.push(`${GRAY}v${version}${RESET}`);

process.stdout.write(parts.join(`${GRAY} · ${RESET}`));
