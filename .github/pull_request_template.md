## Summary

- What changed and why?
- What remains deliberately out of scope?

## Linked issue

Closes #

## Verification

List the exact commands, destinations, and results used to verify this change.

```text
command
result
```

## Evidence

Include screenshots or recordings for visible UI changes. Remove this section when the change has no user-visible output.

## Checklist

Check each applicable item. For a conditional item that does not apply, add `N/A` and a short reason in the pull request description.

- [ ] The change is limited to one implementation issue.
- [ ] Acceptance criteria in the issue are satisfied.
- [ ] If behavior changed, it was developed test-first and has regression coverage.
- [ ] Applicable build, unit, UI, migration, performance, or backup tests pass.
- [ ] If Swift code changed, Swift 6 concurrency checks pass without unexplained unsafe annotations.
- [ ] No scan images, personal databases, backups, private fixtures, or secrets are tracked.
- [ ] If persistence changed, it is versioned, transactional, and migration-tested.
- [ ] If UI changed, it supports accessibility and includes visual evidence.
- [ ] Documentation reflects any changed behavior or architecture.
- [ ] `git diff --check` passes and the branch contains no unrelated changes.
