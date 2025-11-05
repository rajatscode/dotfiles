# Agent Shepherd - PR Review Comment Manager

`agent shepherd` is a command that helps you systematically address PR review comments with AI assistance.

## Quick Start

```bash
# In your PR branch
agent shepherd
```

That's it! Shepherd will find your PR, fetch all review comments, and walk you through them interactively.

## Features

- **Auto-detect PR** from current branch
- **Fetch all review comments** using GitHub CLI
- **Interactive mode** - address each comment one by one
- **AI-powered analysis** - get suggestions for how to address comments
- **Direct integration** - post replies and apply fixes without leaving the terminal
- **Flexible options** - dry-run, auto-apply, or manual control

## Usage

### Basic Usage

```bash
# Auto-detect PR from current branch
agent shepherd

# Specify PR number
agent shepherd --pr=123

# Specify branch
agent shepherd --branch=feature/my-feature
```

### Advanced Usage

```bash
# Dry run - just show comments without interaction
agent shepherd --dry-run

# Auto-apply high-confidence fixes (still asks for confirmation on complex changes)
agent shepherd --auto-apply
```

## What It Does

For each review comment, shepherd:

1. **Shows you the comment:**
   - Comment text and author
   - File path and line number
   - Diff context (what code changed)
   - Surrounding code context

2. **Asks what you want to do:**
   - `1) Investigate & suggest fix` - Use AI to analyze and suggest changes
   - `2) View full file context` - Open the file in your editor/pager
   - `3) Mark as resolved (reply)` - Post a reply to acknowledge the comment
   - `4) Skip for now` - Move to the next comment
   - `q) Quit shepherd` - Exit (you can resume later)

3. **If you choose "Investigate":**
   - Reads the file context around the comment
   - Creates a detailed analysis prompt
   - Uses Claude CLI (if available) to analyze the comment
   - Suggests one of:
     - **FIX** - Specific code changes needed
     - **CLARIFY** - Need more info from reviewer
     - **ACKNOWLEDGE** - Note the comment, no action needed
     - **DEFER** - Address in a future PR
     - **DISAGREE** - Respectfully disagree with the comment
   - Drafts a response to post on the PR
   - Optionally applies fixes and posts responses

## Requirements

### Required
- **Git repository** with a pull request
- **GitHub CLI** (`gh`) installed and authenticated
  ```bash
  gh auth login
  ```

### Optional
- **Claude CLI** for AI-powered comment analysis
  - Without it, shepherd still works but you'll need to analyze comments manually
  - The analysis prompt is saved to a file you can paste into any AI

### Dependencies
- `jq` for JSON parsing (usually pre-installed)
- `bash` 4.0+ (for associative arrays)

## Installation

The shepherd command is built into the `agent` tool. Just make sure you have:

```bash
# Check if agent is available
which agent

# Check if gh CLI is available
which gh

# If not, install gh CLI
# macOS: brew install gh
# Linux: See https://github.com/cli/cli#installation
```

## Examples

### Example 1: Basic Review

```bash
$ cd ~/projects/myapp
$ git checkout feature/new-api
$ agent shepherd

[INFO] Finding PR for current branch: feature/new-api
▶ Shepherding PR #45

PR: #45
Add new API endpoints

State: OPEN

[INFO] Found 3 review comments

Comment 1/3
File: src/api/users.js:23
Author: alice (Jan 15, 2024)
Comment:
  This should validate the email format before saving.

Context:
  @@ -20,6 +20,9 @@ function createUser(data) {
  +  const user = {
  +    email: data.email,
  +    name: data.name

What would you like to do?
  1) Investigate & suggest fix
  2) View full file context
  3) Mark as resolved (reply)
  4) Skip for now
  q) Quit shepherd

Choose action [1-4, q]: 1

[INFO] Using Claude CLI to analyze comment...

Summary: Reviewer wants email validation before saving user data.

Assessment: Currently the code accepts any string as email without validation.
This could lead to invalid data in the database.

Action: FIX (Confidence: HIGH)

Implementation:
- Add email validation using a regex or validation library
- Return error if email is invalid
- Add test for email validation

Response:
Good catch! I'll add email validation using the validator library we're
already using elsewhere in the codebase. Will also add tests.

Would you like to apply this fix? [y/N] y
[WARN] Automatic fix application not yet implemented.
[INFO] Please review the suggested changes above and apply manually.

Post this response to the PR comment? [y/N] y
[SUCCESS] Response posted!

────────────────────────────────────────────────────────

Comment 2/3
...
```

### Example 2: Dry Run

```bash
# See all comments before taking action
$ agent shepherd --dry-run

[INFO] Found 5 review comments

Comment 1/5
File: src/api/users.js:23
...
[DRY RUN] Would analyze and suggest action for this comment

Comment 2/5
...
```

### Example 3: Specific PR

```bash
# Review comments on a specific PR
$ agent shepherd --pr=123

# Or by branch
$ agent shepherd --branch=feature/oauth
```

## Workflow Integration

### With Agent Sessions

Combine shepherd with agent sessions for a complete workflow:

```bash
# Create a session for PR review fixes
agent new pr-review-fixes --branch=feature/my-feature

# Run shepherd to see what needs fixing
agent shepherd

# Work through comments, apply fixes

# When done, push changes
git add .
git commit -m "Address PR review comments"
git push

# Close the session
agent close pr-review-fixes
```

### With CI/CD

You can even run shepherd in CI to check if there are unresolved comments:

```bash
# In your CI script
if agent shepherd --dry-run | grep -q "Found [1-9]"; then
  echo "There are unresolved PR comments"
  exit 1
fi
```

## Tips & Best Practices

### 1. Use Dry Run First

Before making changes, see all comments:
```bash
agent shepherd --dry-run > comments.txt
```

### 2. Batch Similar Comments

If you see multiple comments about the same issue, fix them all at once:
1. Skip through comments with `4` to see all of them
2. Make the fix once
3. Reply to all related comments

### 3. Save Analysis Prompts

The analysis prompts are saved to `/tmp/shepherd-analysis-*.md`. You can:
- Review them later
- Use them with different AI models
- Share them with your team

### 4. Combine with Manual Review

Shepherd is great for systematic review, but:
- Complex architectural discussions might need video calls
- Some comments might need broader context
- Use shepherd for code-level comments, meetings for design discussions

### 5. Keep Track of Progress

Shepherd processes comments in order. If you quit with `q`, just run it again to continue where you left off (or start from the beginning).

## Troubleshooting

### "No PR found for this branch"

Your branch might not have an associated PR yet:
```bash
# Check if PR exists
gh pr list --head $(git branch --show-current)

# Create PR if needed
gh pr create

# Then run shepherd
agent shepherd
```

### "GitHub CLI is not authenticated"

Authenticate with GitHub:
```bash
gh auth login
```

### "Command 'gh' not found"

Install GitHub CLI:
```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Other: https://github.com/cli/cli#installation
```

### Claude CLI not found

Shepherd works without Claude CLI, but AI analysis is disabled:
```bash
# The prompt is saved to /tmp/shepherd-analysis-*.md
# Copy and paste into Claude, ChatGPT, or any AI

# Or install Claude CLI for seamless integration
# See: https://github.com/anthropics/claude-code
```

### "jq: command not found"

Install jq for JSON parsing:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Other: https://stedolan.github.io/jq/download/
```

## Architecture

Shepherd consists of two parts:

1. **Main command** (`agent shepherd`)
   - Fetches PR comments using `gh api`
   - Displays comments with context
   - Provides interactive menu
   - Manages the review flow

2. **Analysis helper** (`agent-shepherd-analyze`)
   - Reads comment and file context
   - Creates analysis prompt
   - Calls Claude CLI (if available)
   - Parses AI suggestions
   - Applies fixes and posts responses

Both scripts are in `/home/user/dotfiles/bin/`.

## Future Enhancements

Planned features:

- [ ] Automatic fix application (currently shows suggestions only)
- [ ] Support for multi-file changes
- [ ] Integration with test runners
- [ ] Comment resolution tracking
- [ ] Batch operations (e.g., "acknowledge all minor comments")
- [ ] Support for issue comments (not just review comments)
- [ ] Template responses for common comment types

## Related Commands

- `agent new` - Create a new agent session
- `agent list` - List all sessions
- `gh pr view` - View PR details
- `gh pr checks` - Check PR CI status
- `gh pr review` - Submit a review

## Contributing

Ideas for improving shepherd? Open an issue or PR!

---

**Happy reviewing! 🧙‍♂️**
