# Cura LulzBot Edition automation scripts and Workflows

## Developer Conan config

LulzBot developers working on Cura LE need to install the conan-config from the `dev` branch in the https://github.com/lulzbot3d/conan-config-le/tree/dev 

```
conan config install https://github.com/lulzbot3d/conan-config-le.git -a "-b dev"
```

## Pipeline caching over workflows

Ported a lot of workflows to this repo. All of the reusable workflows have pipeline chacing enabled for Conan downloads and Conan data folders. The caching key have a default fallback key. This ensures that the cache is updated with the latest changes on the Artifactory remote server but reuses the previous stored downloads and data, greatly reducing our download bandwidth and flexible costs.

The runner conan-config branches have been updated to ensure that the download cache will be in a known location, see: 
- https://github.com/lulzbot3d/conan-config-le/blob/4ddbd291944aff9c22c96a910021afd5f843a034/conan.conf#L6
- https://github.com/lulzbot3d/conan-config-le/blob/1c5134c99284a3ab22fc9cf568e70f5f6a492816/conan.conf#L6
- https://github.com/lulzbot3d/conan-config-le/blob/67e63132cfa48e8b291de6b8204f4b3548788915/conan.conf#L6
- https://github.com/lulzbot3d/conan-config-le/blob/d10578eecbbc37165b495fca6da11a3368e5273e/conan.conf#L6

## Downloading runner pip requirements and helper scripts

Most of the workflows now have a `curl` or `wget` command downloading the pip requirements or OS specific helper scripts from a single source of truth. No longer needing to change the `requirements.txt` of 16 repositories because SIP has a bug.

## No longer tagging to create a release package 

Creating a Conan package release is now done in this repository. See the workflow `conan-package-release.yml` You can specify a Repository and specify the git reference: `main`, `5.7` or a specific git sha. It will check it out and build a conan-package from that commit.

This can be done in as a user action manually or in the future automate it, for instance when we create a Release in Draft mode in the Cura repository. We can then change the conandata.yml pinning the versions and dispatching this `conan-package-release.yml` workflow for the actual repositories. Wait till the workflow are ready, build the Cura LE release with the newly created conan packages and upload the binaries to the GH draft release.

# Conan version and broadcast data

The previous workflow `conan-recipe-version.yml` was buggy and finickle and determined the version based on the git history. This required su to checkout the whole git repo and have complex traversal logic to get the version or bump the version up. Average running time was ~40s in Cura LE repo, this was run for each push in the workflows Unit test.

The current solution gets the _base_ version from `conandata.yml` which should be present in each repo next to `conanfile.py` A `conandata.yml` is automatically accessible as a dict `self.conan_data` in the `ConanFile` class. Since this is a yaml file it can also be easily set and read in Python.

When getting the broadcast data we now do a spare checkout on just the `conandata.yml` obtain the `version` and if it is a `beta` version is runs on a release branch. If the GitHub inputs flags ity as a release it will be a full blown release tag. No more tag, delete, tag, delete etc.

The version can be manually set by a developer by changing them in the conandata.yml, or automatically when we create a feature freeze workflow. **This is yet to be added.** This is also the reason why our own Conan requirements have been moved out of the `conanfile.py` and into the `conandata.yml`

## Benefits:
- Quick workflow from ~40s to ~9s
- Allow for release automation with workflows

## Breaking changes:
- Tagging doesn't create a release anymore
- conandata.yml needs to be present at each repo with a `version` 
- When a PR is made against a release branch it will now use the correct version previously this resulted in minor version bump for the conan-package
- No longer a differentiation for PR in the channel, this wasn't used anyhow

# Conan export package

Has been moved to this repo, it now uses caches between the pipelines to ensure persistence of Conan download cache and Conan data directory. It should always fall back to the latest created cache. For this to work you would make it run specific and than match on the key before the run uuid.

# Conan package create

Same mechanism for pipeline caching as :arrow_up: it even reuses the same cache although it is a different workflow

Split up the workflow in to OS specific workflows, such that we have less complexity on the steps

Moved the system specific installation steps to downloaded scripts from this repo, such that every other workflow which might need them will use the same deps. No longer a need to change them throughout different repos.

# Unit-tests

Now all use a seperate post workflow to ensure that forks can't execute malicious code.

# benchmarks

Check against actors before executing code with write access (no forks or bots)
