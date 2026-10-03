# code-project-flow

English | [中文](README.md)

A **construction-workflow Skill** for AI coding agents. It does not govern *how* code gets written — it governs *when the agent is allowed to start writing*.

Once installed, the agent no longer touches files the moment it receives a request. It writes a plain-language task brief first, stops, waits for your go-ahead, implements, and runs regression exactly once at close-out.

Built for Qoder CLI, and for any agent client that reads the `SKILL.md` format.

---

## Why you need it

AI-assisted coding fails in four predictable ways:

| Failure | What it looks like |
| --- | --- |
| Writes before agreeing | Requirements are still fuzzy, twenty files already changed |
| Drifts further each round | Same spot breaks a second time, so it grows another branch, another wrapper, another flag |
| Context blowup | Every new session re-reads the whole repo, most of it implementation detail this task will never touch |
| Fake green | Tests mock around the real path; passes locally, collapses the moment it ships |

This workflow pins all four down with **four documents + five phases + four overriding principles**.

---

## The four documents

Code detail stays out of the documents. Documents hold decisions only. Each owns one slice, no overlap.

| | File | Who writes it | What it owns |
| --- | --- | --- | --- |
| Doc 1 | `AGENTS.md` | **You, exclusively** | Agent rules, the four overriding principles, document division of labour |
| Doc 2 | `docs/MAP.md` | Agent proposes, you approve | Design: feature choices, project structure, user flow, data flow |
| Doc 3 | `docs/HARNESS.md` | Agent proposes, you approve | Registered regression loops (harnesses) |
| Doc 4 | `docs/TASK.md` | Agent writes, deleted at close-out | The construction plan for *this round only*, down to functions and file paths, written in simplified technical language (ASD-STE100) |

The division that matters:

- **Doc 2 records choices; Doc 4 records how this round lands them.** Same subject: Doc 2 says "blocking cuts follows, push notifications and profile access, but does not delete chat history"; Doc 4 says "modify `blockUser()`, here is what it receives, returns, and returns on failure".
- **Doc 2 only holds what you have actually decided.** Anything missing from its feature section is not part of this project.
- **Doc 4 is disposable.** It is a one-round work order — not archived, not kept in history.
- **A new session reads only Docs 1, 2 and 3.** It does not read the implementations under `harness/`, and does not read deleted task briefs. Context stays stable as a result.
- **The agent's replies follow the same style.** Descriptions, questions and answers use short sentences and common words; function and field names are avoided — when one is unavoidable, it comes with a plain-language explanation first.

Doc 2's eight sections, Doc 3's four sections and Doc 4's seven sections are fixed templates in [`references/`](references/). The agent fills them in when creating the documents.

---

## The five phases

```
READ  →  WRITE BRIEF  →  CONFIRM  →  BUILD  →  CLOSE OUT
          (Doc 4)         ⛔ stop     ✋ no tests   ✋ one run only
```

**1. Read** — Rules and design documents first. If the design doc does not exist, create it by reading the **actual current shape** out of the existing code, not the ideal shape. Leave the structure and the two flows blank and wait for your review before continuing.

**2. Write the task brief** — `docs/TASK.md`, in simplified technical language (ASD-STE100 style), fixed at seven sections:

1. Why this round is happening
2. How it will be done (functions and paths spelled out; **files not listed must not be touched**)
3. What it touches (which component, in which situation, must do what, must not do what)
4. What not to do on the side (write "none" if there is nothing)
5. Conflicts with the design doc (if any, state the replacement sentence)
6. Details that need your sign-off
7. Acceptance boundary for this round (four parts each: which scenario, what action, what must be produced, what must not appear)

**Then stop.** No code changes, no design-doc changes, no harness writing.

**3. Confirm** — Until you explicitly say go, the agent must not start. If the brief needs changes, it changes the brief and stops again.

**4. Build** — If section 5 is not "none", write that sentence into Doc 2 first, then change code. **During the build: no tests, no harness, no verify-as-you-go.** If the scope turns out to be wrong, amend the brief and stop again.

**5. Close out** — Only when the whole block is finished and about to be committed does the agent get its **single** run: check this round against Doc 4 section 7, then run every harness registered in Doc 3. Real data, real flows, **no fake mocks**. If something fails, fix the code — registered items must not be loosened, and entries must not be deleted to buy a green light.

Then the agent proposes write-backs: loops worth keeping go into Doc 3, decisions that will keep affecting future acceptance go into Doc 2, each with the before-sentence and after-sentence listed. **Written only if you agree; dropped if you don't, and never asked twice.** Finally `docs/TASK.md` is deleted.

---

## The four overriding principles

They live in Doc 1. When anything else in this workflow conflicts with them, these win.

- **No patches** — Fix the place that produced the error. Do not add a branch, a wrapper, a compatibility layer, a flag or a "just use it this way for now" special case next to it. One way to do one thing. If the same spot goes wrong a second time, change the structure first.
- **Self-explanatory code** — Names and structure say what the code does. Comments carry only what a reader would guess wrong next time: why it is designed this way, who calls it, what it guarantees and what it does not.
- **No residue** — Functions, files, parameters, flags, commented-out old implementations, stale harnesses and task briefs that this round stopped using get cleaned up at close-out. Temporary solutions are deleted when they expire, not renamed and kept.
- **Deployment parity** — The path that works locally is the path that ships. No special cases for one machine or one environment, no fake data to buy a green light.

---

## Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/PakhomLeo/code-project-flow/main/install.sh | bash
```

Or clone first and read the script before running it (recommended):

```bash
git clone https://github.com/PakhomLeo/code-project-flow.git
cd code-project-flow && ./install.sh
```

### Windows

```powershell
git clone https://github.com/PakhomLeo/code-project-flow.git
cd code-project-flow
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Manual

Drop the whole repository into your skills directory. The folder name must be `code-project-flow`:

```bash
git clone https://github.com/PakhomLeo/code-project-flow.git ~/.qoder-cn/skills/code-project-flow
```

On Windows that is `%USERPROFILE%\.qoder-cn\skills\code-project-flow`.

The install scripts auto-detect `~/.qoder-cn/skills` and `~/.qoder/skills`, defaulting to the former when neither exists. To install elsewhere, pass the target directory as the first argument:

```bash
./install.sh /path/to/your/skills             # macOS / Linux
.\install.ps1 -SkillsRoot C:\path\to\skills   # Windows
```

**Start a new session** afterwards — skills are loaded at session start.

---

## Making it the default

Installing only makes the skill *available*. To route every coding task through this workflow automatically, add one line to your global `~/.qoder-cn/AGENTS.md`:

```markdown
凡写代码、改代码、把功能落到仓库的任务，默认使用 skill code-project-flow。
开工先写 docs/TASK.md 并停下等确认。
```

(The hook line is Chinese because the skill's trigger description is Chinese — keep it verbatim.)

You can also put a project-level `AGENTS.md` in a single repository to scope it there.

Prefer not to set a default? Say "use code-project-flow for this", or mention trigger words like 开工 (start work), 收工 (close out), MAP, 当次说明 (task brief) or harness, and the skill fires.

---

## What using it feels like

```
You:  Add tag filtering to the article list

Agent: (reads AGENTS.md / docs/MAP.md / docs/HARNESS.md)
       docs/TASK.md is written, all seven sections. Highlights:
       - Why: tags are stored but there is no entry point; users can only page
       - How: the article-list query takes a tag parameter; the tag bar shows the current selection
       - Touches: the pager must recompute offset when a tag is present
       - Not on the side: no tag renaming, unrelated to filtering
       - Conflict with design doc: none
       - Needs your sign-off: should an empty tag return everything or nothing?
       - Acceptance boundary: 3 items
       Stopping here, waiting for you.

You:  Empty tag returns everything. Go ahead.

Agent: (builds, no tests mid-way)
       Done. Close-out: ran the 3 items from Doc 4 section 7 against real data.
       Proposing 1 harness for Doc 3: tag filtering must not bypass soft-deletes.
       Keep it?

You:  Keep.

Agent: (writes it into Doc 3, implements it under harness/, deletes docs/TASK.md)
```

Two gates: **before work starts** (the plan) and **at close-out** (the write-backs). Nothing interrupts you in between.

---

## Repository layout

```
code-project-flow/
├── SKILL.md              # skill entry point: the five-phase execution rules
├── references/           # templates for the four documents
│   ├── AGENTS.md         # Doc 1 template → project root
│   ├── MAP.md            # Doc 2 template → docs/MAP.md
│   ├── HARNESS.md        # Doc 3 template → docs/HARNESS.md
│   └── TASK.md           # Doc 4 template → docs/TASK.md (rewritten each round)
├── install.sh            # macOS / Linux installer
├── install.ps1           # Windows installer
├── README.md             # 中文
├── README.en.md          # English
└── LICENSE               # MIT
```

---

## Good fit / bad fit

**Good fit**

- Exploratory projects where whole blocks may be thrown away — the skeleton keeps production-grade boundaries, but security checks, permissions, retries and caching are *not* laid down early
- Long-lived repositories where you are watching AI drift and patches stack on patches
- You want the agent to align on a plan before touching code, rather than reverse-engineering its intent from a diff afterwards

**Bad fit**

- Throwaway scripts and one-off demo pages — the process costs more than it returns
- Requirements you have not thought through yet and expect the agent to discover by writing — this workflow demands a written plan before implementation starts

---

## Customising

`references/AGENTS.md` is **the one file meant for you to edit**. Doc 1's rules are yours alone; the agent must not add, remove or change them on its own.

Tune it per project: swap the "exploratory demo" paragraph for your production bar, tighten or loosen the harness registration threshold, add your team's red lines. Put the edited `AGENTS.md` at the project root — the agent treats it as authoritative and defers to it whenever other instructions conflict.

`SKILL.md` is editable too, but it *is* the workflow body; changes alter how the five phases execute.

---

## Language note

The skill's trigger description and all four document templates are currently **Chinese only**. This README explains the workflow and its concepts in English, but the `SKILL.md` and `references/` files the agent actually reads are Chinese.

That does not affect execution: the agent reads Chinese rules and builds documents from Chinese templates, while your code and comments stay in whatever language your project uses. Issues and PRs adding English templates are welcome.

---

## License

[MIT](LICENSE) © 2026 PakhomLeo
