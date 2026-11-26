# CHANGELOG

# Changes in version \[v1.0.1\] (unreleased)

## New

- All CWL documents are now referenced from a specific release, with a static version number instead of using moving tags like `latest` or `eoap-compliance`. The version for each CWL document may be set in `scripts/stage.sh`
- Each EOAP chapter now includes a short summary of what has been shown
- Added conclusion.qmd (Chapter conclusion) with an overview of the demonstration and limitations of the methodology
- Added the class guided urban material mapping software <https://github.com/ESA-Heatwise/heatwise-class-guided>

## Fixes

- Github workflow to render HTML and PDF targets now doesn't execute each page 3 times (twice for two targets in task `render-website` and once for `render-pdf`). Now it is executed only once, using `render-website-pdf` as a deliberate multi-target task and using `--cache` to avoid executing twice for both targets.

## Improvements

- `stage` now pre-downloads Docker images. The first target to be rendered no longer includes lengthy output from Docker pull.
- Github workflow to render HTML and PDF targets is no-longer excuted on pull request
- Requirements with lists are now rendered correctly as lists
- Some checks are made more comprehensive: Output STAC may have `start_datetime` and `end_datetime` instead of a `datetime` field. The version may also be specified as `https://schema.org/version` (previously: only `s:version` was checked).
