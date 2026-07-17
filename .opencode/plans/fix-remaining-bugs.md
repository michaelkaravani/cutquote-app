# Remaining Bug Fixes

## Bug A — `quote_actions.dart:116`
**Problem:** `onUpdated(docId, newStatus)` called after `await` without `context.mounted` check.
**Fix:** Add `if (!context.mounted) return;` before line 116.

## Bug B — `quote_actions.dart:143`
**Problem:** `onRollback(index, quote)` called after `await` before the `mounted` check on line 144.
**Fix:** Move `if (!context.mounted) return;` before `onRollback(index, quote);`

## Bug C — `login_screen.dart:250`
**Problem:** `dialogSetState` called in `finally` block after `dialogNavigator.pop()` closed the dialog.
**Fix:** Guard with `if (dialogContext.mounted)` before calling `dialogSetState`.

## Bug D — 5 PDF templates (TOCTOU)
**Problem:** Redundant `await logoFile.exists()` check before `await logoFile.readAsBytes()` creates race window.
**Fix:** Remove the exists check; let the existing `catch (_) {}` handle any errors.
