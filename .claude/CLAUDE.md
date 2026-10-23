# User instructions (global)

Personal engineering guidelines applied across all projects, in addition to each repo's own CLAUDE.md. Distilled from experience and code/PR review feedback. Add a new entry whenever a review comment reveals a habit worth keeping or breaking. Keep entries short and actionable — principle first, then the why.

## Answering

- **Default to short, simple, to-the-point answers.** Lead with the answer or recommendation, in a few bullets or a short paragraph. Cut background, alternatives, and caveats unless they change the decision. Go in depth only when explicitly asked for more detail.
- **Plain language, no metaphors or analogies** (no "it's like a car in a traffic jam"). State the thing directly.
- **When explaining something, add real examples of the thing itself.** Take them from the actual source: a document from the database, a real page or URL, a value from the config, a line from the code, or a documented case from the wiki or online docs. The example must describe the explained thing directly. A metaphor ("imagine it like ...") is not an example.

  Why: long answers bury the useful part; the value is in quick, clear, actionable replies. A real example shows how the thing behaves on real data, which a metaphor cannot.

## Secrets and private files

- **Never read the contents of secret files. Only check that something exists.** This covers `.env` files, credentials, keys, tokens, and other private data. Allowed: check that a file or folder exists (`test -f .env`), or check that a key is present without printing its value (`grep -q '^API_KEY=' .env`). Not allowed: reading the whole file (`cat`, `head`, the Read tool), or any command that prints a secret value (plain `grep` prints the whole matching line).
- **If you read secret content anyway, report it right away with 🚨.** Start the message with 🚨, name the file, and say which values were exposed, so the user can rotate them.

  Why: anything read into the conversation leaves the machine and can end up in logs. An existence check answers the question without exposing the value.

## Writing code

1. **Write simple, readable code.** Optimize for other human programmers: code should be easy to read, easy to review, and easy to extend or delete later. Prefer the straightforward solution over the clever one.
2. **Comments must earn their place.** Put a short description on bigger units (classes, long functions) explaining what the component is for. Beyond that, comment only the hidden reasons — non-obvious behavior and product decisions (why something is the way it is). Keep inline comments short and don't overfill the code with them.
3. **Checks must earn their place too.** Do check for None values and handle plausible exceptions, but don't guard every little thing — no checks for conditions that can't actually happen. Keep validation within limits.

## Typing

- **Prefer typed code; the baseline is typed function signatures.** In Python, annotate every function's arguments and return value (`def get(self, prompt_id: str) -> MatchingPrompt | None:`); in the JS world prefer TypeScript over plain JS. Local variables usually don't need annotations — the signature is the contract, and inference covers the rest. Match the style the codebase already uses for optionals/unions (e.g. `str | None` vs `Optional[str]`).

  Why: typed signatures document intent where callers look, let tooling catch mismatches before runtime, and make refactors (like a dict → model switch) mechanical instead of guesswork.

## Testing

- **Don't write trivial tests that only exercise a mock, fake, or a library primitive.** A test that stores a value in a mock and asserts it reads back the same value proves nothing about our code. Test real behavior: branching logic, parsing/serialization edge cases, error handling. If removing the production logic wouldn't fail the test, the test isn't worth writing.

## Architecture

- **Put code in the layer that owns it (MVC/MVT-style separation of concerns).** When a codebase has repository / model / service layers, respect them:
  - **Repository** — data access only: collection name, indexes, thin query helpers. No business rules.
  - **Model** — a typed class per managed entity (fields, serialization). Consumers use attributes, not raw dicts.
  - **Service** — the business logic: validation, id generation, reference checks, cross-entity rules. One service owns each entity's lifecycle.
  - **UI / widget / controller** — thin: render, call the service, display errors. No validation or persistence logic.

  Why: logic dropped into the nearest convenient file (a widget, a repo) gets duplicated, untested, and invisible to other callers. When adding a feature, mirror how the neighboring entity is structured (a new managed entity gets model + repository + service like the existing ones) — don't shortcut because the logic feels small; small logic grows.

## Backward compatibility

- **Question whether legacy/back-compatibility code is actually needed before adding it.** Don't reflexively add fallback branches for an old data format. First ask: *will old-format data actually exist once this ships? Or will it exist only for a limited time that is not hurtful?* If the data is only produced by the new code path (e.g. written only on-demand, so no machine carries the old format after deploy), or persists only for a short time and does no harm, skip the legacy handling entirely. Dead compatibility code is a permanent maintenance cost for a case that can never occur.

## Git: commits and pull requests

- **Commit title: type prefix, short text, ticket id at the end.** Use the Conventional Commits types (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, ...), then a short summary, then the ticket id in parentheses when the work has one. Example: `feat: limit the free product sample to 20% of live products (DEV-779)`.
- **Commit description: a short, factual paragraph with the context the title cannot carry.** Skip it only when the title already says everything (for example a one-file change fully described by the title). Otherwise prefer a short description: what changed and why, to the point, not too long, so reviewers get what they need to know.
- **PR description: a bullet-point summary plus the Linear link.** A few bullets of what has been done, and a link to the Linear issue where the business need behind the PR is explained.

  Why: the type prefix and the ticket id make the history searchable and tie the code to the reason it was written. The short description and the Linear link give reviewers the context without asking.

## Comments and replies (PR, Linear, Slack)

- **Never post or reply automatically. Always ask for confirmation first.** This covers PR comments, review-thread replies, resolving review threads, Linear comments and Slack messages. Draft the text, show it in the chat, and post only after an explicit go.

  Why: a comment speaks for me to the team and cannot be unsent; I want to see every word before it goes out.
