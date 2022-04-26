# Releasing Guide

In order to release new version of the repository:

1. Ensure all required pull requests have been merged
1. Add and push new tag:

   ```bash
   export TAG="${FLUENTD_VERSION}-sumo-x"
   git tag -sm "${TAG}" "${TAG}"
   git push origin "${TAG}"
   ```

1. Create [release][new_release] with [auto-generated release notes][auto_generate_notes]

[new_release]: https://github.com/SumoLogic/sumologic-kubernetes-fluentd/releases/new
[auto_generate_notes]: https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes
