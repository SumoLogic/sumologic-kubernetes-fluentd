#!/usr/bin/env bash

# shellcheck disable=SC2154

err_report() {
    echo "Script error on line $1"
    exit 1
}
trap 'err_report $LINENO' ERR

function bundle_fluentd_plugin() {
  local plugin_name="${1}"
  local version="${2}"
  # Strip everything after "-" (longest match) to avoid gem prerelease behavior
  local gem_version="${version%%-*}"

  if [[ -z "${version}" ]] ; then
    echo "Please provide the version when bundling fluentd plugins"
    exit 1
  fi
  pushd "${plugin_name}" || exit 1

  echo "Building gem ${plugin_name} version ${gem_version} in $(pwd) ..."
  sed -i.bak "s/0.0.0/${gem_version}/g" ./"${plugin_name}".gemspec
  rm -f ./"${plugin_name}".gemspec.bak

  echo "Install bundler..."
  bundle install

  echo "Build gem ${plugin_name} ${gem_version}..."
  gem build "${plugin_name}"
  mv ./*.gem ../gems
  popd || exit 1
}

function bundle_fluentd_plugins() {
  local version="${1}"

  if [[ -z "${version}" ]] ; then
    echo "Please provide the version when bundling fluentd plugins"
    exit 1
  fi

  find . -maxdepth 1 -name 'fluent-plugin-*' -type 'd' -print |
    while read -r line; do
      # Run tests in their own context
      (bundle_fluentd_plugin "$(basename "${line}")" "${version}") || exit 1
    done
}

function set_up_github() {
  git config --global user.name "Continuous Integration [bot]"
}

function push_docker_image() {
  local version="$1"
  local docker_tag="$2"

  echo "Tagging docker image ${docker_tag}:local with ${docker_tag}:${version}..."
  docker tag "${docker_tag}:local" "${docker_tag}:${version}"
  echo "Pushing docker image ${docker_tag}:${version}..."
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
  docker push "${docker_tag}:${version}"
}

function build_docker_image() {
  local tag
  local no_cache
  tag="${1}"

  echo "Building docker image with ${tag}:local in $(pwd)..."
  no_cache="--no-cache"
  if [[ "${DOCKER_USE_CACHE}" == "true" ]]; then
    no_cache=""
  fi
  docker build . -t "${tag}:local" ${no_cache:+"--no-cache"}
  rm -f ./gems/*.gem

  # echo "Test docker image locally..."
  # ruby deploy/test/test_docker.rb || exit 1
}

function is_checkout_on_tag() {
  git describe --exact-match --tags HEAD 2>/dev/null
}

function fetch_current_branch() {
  # No need to fetch when we can already do 'git describe ...'
  git describe --tags >/dev/null && return

  # No need to fetch full history with:
  # git fetch --tags --unshallow
  # Just fetch the current branch and its tags so that git describe works.
  local BRANCH
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"

  # Need to check if repo is shallow because:
  # "fatal: --unshallow on a complete repository does not make sense"
  # and we need to unshallow the repository because otherwise we'd get:
  # fatal: No tags can describe '<SHA>'.
  # Try --always, or create some tags.
  if [[ "true" == "$(git rev-parse --is-shallow-repository)" ]]; then
    git fetch -v --tags --unshallow origin "${BRANCH}"
  else
    git fetch -v --tags origin "${BRANCH}"
  fi
}
