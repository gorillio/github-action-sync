# Upstream Sync Github Action

Github Action to public upstream repo commits to the private repo.

Most of the projects have Release branches and master branch. Master branch is where
developers works on but we want to push the changes to the Release branches too. 


## Action

* Pull the upstream
* Get the last commit SHA
* Check if that exists on internal `branch`
* If not, create a pull request

## Inputs

#### `upstream`

**Required** Upstream repo  

#### `upstream_branch`

**Required** Upstream branch to pull from  

#### `branch`

**Required** Branch to merge to  

#### `pr_labels`

Labels for the new PR

## Example usage 

```
name: Pull upstream
on:
  schedule:
    # * is a special character in YAML so you have to quote this string
    - cron:  '0 * * * *'
jobs:
  release_pull_request:
    runs-on: ubuntu-latest
    name: release_pull_request
    steps:
    - name: checkout
      uses: actions/checkout@v1
    - name: Create PR to branch
      uses: gorillio/github-action-sync@master
      with:
        upstream: git@github.com:apache/XXX.git
        upstream_branch: master
        branch: master
        pr_labels: upstream
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GITBOT_EMAIL: yo@gorill.io
        DRY_RUN: false
```
