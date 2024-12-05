# Cura LulzBot Edition Workflows and Automation Scripts

## Install LulzBot Conan Config

```bash
conan config install https://github.com/lulzbot3d/conan-config-le.git
```

## Pipeline Caching Over Workflows

Most repository workflows have been ported to this one and made reusable to cut down on repeated code. They all have pipeline caching enabled for Conan downloads and Conan data folders. The caching key has a default fallback key. This ensures that the cache is updated with the latest changes on the Artifactory remote server but reuses the previous stored downloads and data, greatly reducing our download bandwidth and flexible costs.

The runner conan-config-le branches have been updated to ensure that the download cache will be in a known location, see:

- [Linux](https://github.com/lulzbot3d/conan-config-le/blob/runner/Linux/X64/conan.conf)
- [macOS \(X64\)](https://github.com/lulzbot3d/conan-config-le/blob/runner/macOS/X64/conan.conf)
- [macOS \(ARM64\)](https://github.com/lulzbot3d/conan-config-le/blob/runner/macOS/ARM64/conan.conf)
- [Windows](https://github.com/lulzbot3d/conan-config-le/blob/runner/Windows/X64/conan.conf)

## Downloading runner pip Requirements and Helper Scripts

Most of the workflows now have a `curl` or `wget` command downloading the pip requirements or OS specific helper scripts from a single source of truth. No longer needing to change the `requirements.txt` of 16 repositories because SIP has a bug.

## No Longer Tagging to Create a Release Package

Creating a Conan package release is now done in this repository. See the workflow [`conan-package-release.yml`](https://github.com/lulzbot3d/CuraLE_Workflows/actions/workflows/conan-package-release.yml) You can specify a Repository and the git reference: `main`, `5.7` or a specific git sha. It will check it out and build a conan-package from that commit.

This can be done in as a user action manually or in the future automate it, for instance when we create a Release in Draft mode in the CuraLE repository. We can then change the conandata.yml pinning the versions and dispatching this `conan-package-release.yml` workflow for the actual repositories. Wait until the workflows are ready, build the CuraLE release with the newly created conan packages, and upload the binaries to the GH draft release.

## Conan Version and Broadcast Data

The previous workflow `conan-recipe-version.yml` was buggy and determined the version based on the git history. This required checking out the whole git repo and having complex traversal logic to get the version or bump the version up. Average running time was ~40s in the CuraLE repo, and this was run for each push.

The current solution gets the _base_ version from `conandata.yml` which should be present in each repo next to `conanfile.py` A `conandata.yml` is automatically accessible as a dict `self.conan_data` in the `ConanFile` class. Since this is a yaml file it can also be easily set and read in Python.

When getting the broadcast data we now do a spare checkout on just the `conandata.yml`, obtain the `version`, and if it is a `beta` version it runs on a release branch. If the GitHub inputs flags it as a release it will be a full blown release tag. No more tag, delete, tag, delete etc.

The version can be manually set by a developer by changing the conandata file, or automatically when we create a feature freeze workflow. **This, however, is yet to be added.** This is also the reason why our own Conan requirements have been moved out of the `conanfile.py` and into the `conandata.yml`

### Benefits

- Much faster workflow, down from ~40s to ~9s
- Allow for release automation with workflows

### Breaking changes

- Tagging doesn't create a release anymore
- `conandata.yml` now needs to be present in each repo with a `version` key
- When a PR is made against a release branch, it will now use the correct version. Previously, this resulted in minor version bump for the conan-package
- There is longer a differentiation for PR in the channel, but this wasn't used

## Conan export-package

Has been moved to this repo, it now uses caches between the pipelines to ensure persistence of Conan download cache and Conan data directory. It should always fall back to the latest created cache. For this to work you would make it run specific and than match on the key before the run UUID.

## Conan package-create

Same mechanism for pipeline caching as export, it even reuses the same cache although it is a different workflow

We've split up the workflow in to OS specific workflows, such that we have less complexity on each step

We've also moved the system specific installation steps to downloaded scripts from this repo, such that every other workflow which might need them will use the same dependencies. There's no longer a need to change them throughout different repos.

## Unit Tests

Now all unit tests use a seperate post-workflow to ensure that forks can't execute malicious code.

## Benchmarks

Check against actors before executing code with write access (no forks or bots)
