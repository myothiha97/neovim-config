# Config Maintenance & Delegation Plan

How I intend to keep this Neovim config maintained over the long term **without**
letting it consume the time I owe to my professional work. As the config has
grown complex, the realistic future is: less free time, and not every fix worth
doing personally.

> Read [`../rules.md`](../rules.md) first — this doc is the detailed version of
> the "Delegation & long-term maintenance" rule. The rules file decides *whether
> and when* to touch the config; this file decides *who* does a given fix.

---

## The core principle

My time is the scarce resource, and it is owed to the professional job — not to
maintaining an editor config. So the question for any bug or maintenance item is
not "can I fix this?" but **"is this worth *my* hours?"**

The config working reliably matters. *Who* makes it work reliably does not.

## The 30-minute rule

The single decision gate for any bug, issue, or maintenance task:

- **Quick fix — can be done within ~30 minutes → I do it myself.**
  Fast, low-analysis, obvious cause and fix. Cheaper to just handle it than to
  hand it off.
- **Not a quick fix — needs real analysis or extended time → delegate it.**
  Even if the *visible symptom* is small or cosmetic, if diagnosing and fixing
  it properly would take meaningful time, it is a candidate to shift off my
  plate rather than sink my own hours into.

The trap to avoid: a small-looking symptom that hides a deep cause. The size of
the *output* of a bug is not the size of the *fix*. Judge by fix effort, not by
how minor the annoyance looks.

## Ways to delegate

Options for shifting work off my plate, roughly in order of weight:

- **Code review by another dev** — for changes I've drafted but want a second
  set of eyes on before they land, especially around performance and breakage.
- **Part-time / for-a-fee dev** — for bugs and minor maintenance that are
  annoying, time-consuming to analyze, and not a quick fix. Pay to reclaim the
  hours.
- Reserve my own deep focus for the things only I can or want to do.

## What stays mine vs. what gets delegated

| Task type | Who | Why |
| --- | --- | --- |
| Quick fix (≤ 30 min) | Me | Faster to just do it |
| Deep/slow fix, small symptom | Delegate | Output looks small, effort isn't |
| Annoying minor maintenance | Delegate | Not worth my limited hours |
| Routine code review | Delegate / extra dev | Frees focus for real work |
| Core direction & decisions | Me | Owner judgment, not outsourceable |

## When to revisit this plan

- If free time changes materially (more or less).
- If the config stabilizes enough that maintenance load drops near zero.
- If a trustworthy dev relationship makes delegation cheaper/easier than assumed.

This is a *future* plan — not in effect until free time actually becomes the
binding constraint. Until then, the [`rules.md`](../rules.md) freeze policy is
what's doing the work.
