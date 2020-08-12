#!/bin/sh -l

git_setup() {
  cat <<- EOF > $HOME/.netrc
    machine github.com
    login $GITHUB_ACTOR
    password $GITHUB_TOKEN
    machine api.github.com
    login $GITHUB_ACTOR
    password $GITHUB_TOKEN
EOF
  chmod 600 $HOME/.netrc

  git config --global user.email "$GITBOT_EMAIL"
  git config --global user.name "$GITHUB_ACTOR"
}

git_cmd() {
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    echo $@
  else
    eval $@
  fi
}

git_setup
git_cmd git remote add upstream ${INPUT_UPSTREAM}
git_cmd git fetch --all

last_sha=$(git_cmd git rev-list -1 upstream/${INPUT_UPSTREAM_BRANCH})
up_to_date=$(git_cmd git rev-list origin/${INPUT_BRANCH} | grep ${last_sha} | wc -l)
pr_branch="up-${last_sha}"

pr_exists=$(git_cmd hub pr list | grep ${last_sha} | wc -l)
if [[ "${pr_exists}" -gt 0 ]]; then
 echo "PR Already exists!!!"
 git_cmd hub pr list | grep ${last_sha}
 exit 0
fi

if [[ "${up_to_date}" -gt 0 ]]; then
  git_cmd git checkout -b "${pr_branch}" --track "upstream/${INPUT_UPSTREAM_BRANCH}"
  git_cmd git push -u origin "${pr_branch}"
  git_cmd hub pull-request -b "${INPUT_PR_BRANCH}" -h "${pr_branch}" -l "${INPUT_PR_LABELS}" -a "${GITHUB_ACTOR}" -m "\"Upstream: ${last_sha}\""
else
  echo "Branch up-to-date"
  exit 0
fi
