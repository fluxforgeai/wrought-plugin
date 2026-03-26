# Genesis Demo Mode Reference

> Only execute this section if mode is `demo`. Skip all genesis phases (1-3) and Completion.

### Step D1: Present Demo Picker

Use AskUserQuestion: "Which demo would you like to try?"
- "Build a REST API (Proactive pipeline, ~30min) — Build a task management API from scratch using /finding -> /design -> /blueprint -> /implement -> /review"
- "Fix a Production Bug (Reactive pipeline, ~20min) — Find and fix a race condition using /incident -> /investigate -> /rca-bugfix -> /rca-fix -> /review"
- "Audit a Legacy Codebase (Audit pipeline, ~40min) — Audit an Express.js app for security and quality issues using /analyze -> /finding -> /investigate -> /fix -> /review"

Map selection to demo file:
- REST API -> `demos/rest_api.md`
- Bug Fix -> `demos/bug_fix.md`
- Audit -> `demos/audit.md`

### Step D2: Scaffold Demo Project

1. Read the selected demo file
2. Create project directory: `demo-rest-api/`, `demo-bug-fix/`, or `demo-audit/`
3. For each `<!-- file: {path} -->` marker in the demo file, extract the immediately following code block and write it to `{project_dir}/{path}`
4. Extract the content between `<!-- walkthrough -->` and `<!-- /walkthrough -->` markers and write it to `{project_dir}/DEMO_WALKTHROUGH.md`

### Step D3: Print Summary

Print the scaffolded file tree, then:

```
Demo scaffolded! Open DEMO_WALKTHROUGH.md to get started:

  Read {project_dir}/DEMO_WALKTHROUGH.md

The walkthrough will guide you through the {pipeline_type} pipeline step by step.
```

**STOP.** Do NOT proceed beyond this point. Do NOT run pipeline commands. Let the user follow the walkthrough at their own pace.
