# CHANGELOG

# Changes in version \[v1.0.1\] (unreleased)

## Fixes

- Github workflow to render HTML and PDF targets now doesn't execute each page 3 times (twice for two targets in task `render-website` and once for `render-pdf`). Now it is executed only once, using `render-website-pdf` as a deliberate multi-target task and using `--cache` to avoid executing twice for both targets.

## Improvements

- `stage` now pre-downloads Docker images. The first target to be rendered no longer includes lengthy output from Docker pull.
- Github workflow to render HTML and PDF targets is no-longer excuted on pull request
