# CI Pipeline Testing

I am using GitHub with CI workflow with super-linter at work.
I want that in my GitLab CI pipeline.
All attempts so far have resulted in various levels of failure.
This is to track what works, and does not.

[super-linter](https://github.com/super-linter/super-linter)

## Branches

Several branches have been created to test different versions of ''.gitlab-ci.yml''
Each branch is named after an expected goal to resolve the issue.

### basic-super-linter

This does not load super-linter at all,
it is just a basic YML to test a pipeline action.

### default-super-linter

This does not load super-linter at all,
it is just a default YML to test a pipeline action.

### docker-super-linter

This tests using the super-linter docker image in the YML.
This has a failure of not being able to mount the CI_PROJECT_DIR
path as a Docker volume to the ''/tmp/lint'' mount point as
needed by super-linter.

## ENV Dump

The ''env'' command was able to show useful variables when the basic was tested.

```bash

Running with gitlab-runner 18.4.0~pre.246.g71914659 (71914659)
  on green-3.saas-linux-small-amd64.runners-manager.gitlab.com/default Jhc_Jxvh8, system ID: s_0e6850b2bce1
Preparing the "docker+machine" executor
00:22
Using Docker executor with image node:latest ...
Using effective pull policy of [always] for container node:latest
Pulling docker image node:latest ...
Using docker image sha256:b514aab1b25fb57dc80b74d260ddd43125f66249287c6a6b26e356e6684c6552 for node:latest with digest node@sha256:9e69791906aaabda0fc123beb81861d53bcdf4e9611c15df0b916fff5c1ccc02 ...
Preparing environment
00:06
Using effective pull policy of [always] for container sha256:17294db5bee693291b3f41bb16a29a144f5553dfd513efbb6adf37c2b586c46c
Running on runner-jhcjxvh8-project-74394513-concurrent-0 via runner-jhcjxvh8-s-l-s-amd64-1765621974-ef55e52b...
Getting source from Git repository
00:01
Gitaly correlation ID: 3105bb6acfc54b9b812bc375d9bce6da
Fetching changes with git depth set to 20...
Initialized empty Git repository in /builds/SiliconTao-Systems/STFjord/.git/
Created fresh repository.
Checking out ccea8b43 as detached HEAD (ref is refs/merge-requests/3/head)...
Skipping Git submodules setup
$ git remote set-url origin "${CI_REPOSITORY_URL}" || echo 'Not a git repository; skipping'
Executing "step_script" stage of the job script
00:01
Using effective pull policy of [always] for container node:latest
Using docker image sha256:b514aab1b25fb57dc80b74d260ddd43125f66249287c6a6b26e356e6684c6552 for node:latest with digest node@sha256:9e69791906aaabda0fc123beb81861d53bcdf4e9611c15df0b916fff5c1ccc02 ...
$ echo "Set the GITHUB_SHA value to the commit SHA"
Set the GITHUB_SHA value to the commit SHA
$ export GITHUB_SHA=$(git rev-parse HEAD)
$ env
CI_DEFAULT_BRANCH_SLUG=master
CI_PROJECT_NAMESPACE=SiliconTao-Systems
GITLAB_USER_ID=2940166
CI_RUNNER_VERSION=18.4.0~pre.246.g71914659
CI_MERGE_REQUEST_TARGET_BRANCH_PROTECTED=true
FF_SKIP_NOOP_BUILD_STAGES=true
FF_USE_INIT_WITH_DOCKER_EXECUTOR=false
CI_SERVER_NAME=GitLab
CI_RUNNER_DESCRIPTION=3-green.saas-linux-small-amd64.runners-manager.gitlab.com/default
GITLAB_USER_EMAIL=osgnuru@gmail.com
CI_SERVER_REVISION=fee1fb1740c
CI_MERGE_REQUEST_SOURCE_BRANCH_PROTECTED=false
FF_USE_WINDOWS_LEGACY_PROCESS_STRATEGY=false
CI_MERGE_REQUEST_SOURCE_BRANCH_NAME=add-gh-linter
CI_MERGE_REQUEST_TARGET_BRANCH_SHA=
CI_RUNNER_EXECUTABLE_ARCH=linux/amd64
CI_PIPELINE_NAME=
CI_REGISTRY_USER=gitlab-ci-token
CI_PROJECT_TOPICS=infrastructure-as-code (iac),iac,terraform,rocky linux,digitalocean,cloud,bash
CI_API_V4_URL=https://gitlab.com/api/v4
CI_REGISTRY_PASSWORD=[MASKED]
CI_RUNNER_SHORT_TOKEN=Jhc_Jxvh8
CI_JOB_NAME=super-linter
CI_OPEN_MERGE_REQUESTS=SiliconTao-Systems/STFjord!3
HOSTNAME=runner-jhcjxvh8-project-74394513-concurrent-0
GITLAB_USER_LOGIN=RoyceTheBiker
CI_PROJECT_NAME=STFjord
CI_PIPELINE_SOURCE=merge_request_event
CI_JOB_STATUS=running
CI_PIPELINE_ID=2212955552
FF_DISABLE_POWERSHELL_STDIN=false
CI_COMMIT_REF_SLUG=add-gh-linter
CI_MERGE_REQUEST_SOURCE_PROJECT_PATH=SiliconTao-Systems/STFjord
CI_SERVER=yes
FF_SET_PERMISSIONS_BEFORE_CLEANUP=true
YARN_VERSION=1.22.22
CI_COMMIT_SHORT_SHA=ccea8b43
CI_JOB_NAME_SLUG=super-linter
RUNNER_TEMP_PROJECT_DIR=/builds/SiliconTao-Systems/STFjord.tmp
CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX=gitlab.com:443/silicontao-systems/dependency_proxy/containers
FF_USE_GIT_BUNDLE_URIS=true
PWD=/builds/SiliconTao-Systems/STFjord
CI_RUNNER_TAGS=["gitlab--duo", "saas-linux-small-amd64"]
CI_MERGE_REQUEST_DIFF_BASE_SHA=991f39dcaf3635dc5ca88c8257bf187485367cc2
CI_PROJECT_PATH=SiliconTao-Systems/STFjord
CI_MERGE_REQUEST_SOURCE_PROJECT_URL=https://gitlab.com/SiliconTao-Systems/STFjord
FF_HASH_CACHE_KEYS=false
CI_PROJECT_NAMESPACE_SLUG=silicontao-systems
FF_TIMESTAMPS=false
FF_USE_NEW_BASH_EVAL_STRATEGY=false
FF_MASK_ALL_DEFAULT_TOKENS=true
CI_SERVER_TLS_CA_FILE=/builds/SiliconTao-Systems/STFjord.tmp/CI_SERVER_TLS_CA_FILE
CI_DEPENDENCY_PROXY_DIRECT_GROUP_IMAGE_PREFIX=gitlab.com:443/silicontao-systems/dependency_proxy/containers
CI_MERGE_REQUEST_PROJECT_URL=https://gitlab.com/SiliconTao-Systems/STFjord
FF_USE_LEGACY_S3_CACHE_ADAPTER=false
GITHUB_SHA=ccea8b431ba7c158b79a184cb13aa0a4eb293c59
CI_MERGE_REQUEST_DESCRIPTION_IS_TRUNCATED=false
FF_WAIT_FOR_POD_TO_BE_REACHABLE=false
CI_JOB_GROUP_NAME=super-linter
FF_DISABLE_UMASK_FOR_KUBERNETES_EXECUTOR=false
CI_COMMIT_REF_PROTECTED=false
FF_USE_POWERSHELL_PATH_RESOLVER=false
CI_MERGE_REQUEST_TITLE=Analyze system security.
FF_USE_DOCKER_AUTOSCALER_DIAL_STDIO=true
CI_API_GRAPHQL_URL=https://gitlab.com/api/graphql
CI_SERVER_VERSION_MINOR=7
CI_COMMIT_SHA=ccea8b431ba7c158b79a184cb13aa0a4eb293c59
HOME=/root
FF_NETWORK_PER_BUILD=false
CI_DEPENDENCY_PROXY_PASSWORD=[MASKED]
CI_JOB_TIMEOUT=3600
CI_PROJECT_VISIBILITY=public
CI_CONCURRENT_PROJECT_ID=0
FF_SCRIPT_SECTIONS=false
CI_COMMIT_MESSAGE=testy
FF_USE_WINDOWS_JOB_OBJECT=false
DOCKER_TLS_CERTDIR=
CI_SERVER_SHELL_SSH_PORT=22
FF_DISABLE_AUTOMATIC_TOKEN_ROTATION=false
FF_USE_DIRECT_DOWNLOAD=true
CI_PAGES_DOMAIN=gitlab.io
FF_PRINT_POD_EVENTS=false
CI_SERVER_VERSION=18.7.0-pre
CI_MERGE_REQUEST_PROJECT_PATH=SiliconTao-Systems/STFjord
FF_USE_POD_ACTIVE_DEADLINE_SECONDS=true
CI_REGISTRY=registry.gitlab.com
CI_SERVER_PORT=443
CI_MERGE_REQUEST_IID=3
CI_PAGES_HOSTNAME=stfjord-c650fc.gitlab.io
CI_PROJECT_NAMESPACE_ID=7428459
FF_TEST_FEATURE=false
CI_MERGE_REQUEST_DESCRIPTION=
CI_MERGE_REQUEST_PROJECT_ID=74394513
CI_PAGES_URL=https://stfjord-c650fc.gitlab.io
CI_MERGE_REQUEST_ID=440312457
CI_PIPELINE_IID=11
CI_REPOSITORY_URL=https://gitlab-ci-token:[MASKED]@gitlab.com/SiliconTao-Systems/STFjord.git
FF_USE_FLEETING_ACQUIRE_HEARTBEATS=false
CI_SERVER_URL=https://gitlab.com
FF_ENABLE_BASH_EXIT_CODE_CHECK=false
GITLAB_FEATURES=data_management,ldap_group_sync,multiple_ldap_servers,seat_link,seat_usage_quotas,pipelines_usage_quotas,transfer_usage_quotas,zoekt_code_search,usage_billing,repository_size_limit,elastic_search,admin_audit_log,auditor_user,custom_file_templates,custom_project_templates,db_load_balancing,default_branch_protection_restriction_in_groups,extended_audit_events,external_authorization_service_api_management,geo,instance_level_scim,ldap_group_sync_filter,object_storage,pages_size_limit,project_aliases,disable_private_profiles,password_complexity,amazon_q,enterprise_templates,git_abuse_rate_limit,integrations_allow_list,required_ci_templates,runner_maintenance_note,runner_performance_insights,runner_upgrade_management,observability_alerts
CI_MERGE_REQUEST_DRAFT=false
FF_USE_GITALY_CORRELATION_ID=true
CI_MERGE_REQUEST_REF_PATH=refs/merge-requests/3/head
CI_COMMIT_DESCRIPTION=
DOCKER_IPTABLES_LEGACY=1
FF_USE_ADVANCED_POD_SPEC_CONFIGURATION=false
CI_TEMPLATE_REGISTRY_HOST=registry.gitlab.com
CI_JOB_STAGE=test
CI_MERGE_REQUEST_DIFF_ID=1599339161
CI_PIPELINE_URL=https://gitlab.com/SiliconTao-Systems/STFjord/-/pipelines/2212955552
FF_EXPORT_HIGH_CARDINALITY_METRICS=false
CI_DEFAULT_BRANCH=master
FF_GIT_URLS_WITHOUT_TOKENS=false
CI_MERGE_REQUEST_TARGET_BRANCH_NAME=master
CI_MERGE_REQUEST_SOURCE_BRANCH_SHA=
GITLAB_ENV=/builds/SiliconTao-Systems/STFjord.tmp/gitlab_runner_env
CI_MERGE_REQUEST_SQUASH_ON_MERGE=false
CI_SERVER_VERSION_PATCH=0
CI_COMMIT_TITLE=testy
CI_SERVER_FQDN=gitlab.com
CI_PROJECT_ROOT_NAMESPACE=SiliconTao-Systems
FF_ENABLE_JOB_CLEANUP=false
FF_RESOLVE_FULL_TLS_CHAIN=false
GITLAB_USER_NAME=RoyceTheBiker
CI_MERGE_REQUEST_SOURCE_PROJECT_ID=74394513
CI_PROJECT_DIR=/builds/SiliconTao-Systems/STFjord
CI_MERGE_REQUEST_EVENT_TYPE=detached
SHLVL=1
CI_RUNNER_ID=12270852
CI_PIPELINE_CREATED_AT=2025-12-13T10:33:41Z
CI_COMMIT_TIMESTAMP=2025-12-13T03:33:32-07:00
CI_DISPOSABLE_ENVIRONMENT=true
CI_SERVER_SHELL_SSH_HOST=gitlab.com
CI_REGISTRY_IMAGE=registry.gitlab.com/silicontao-systems/stfjord
CI_SERVER_PROTOCOL=https
CI_COMMIT_AUTHOR=Royce Souther <osgnuru@gmail.com>
FF_POSIXLY_CORRECT_ESCAPES=false
CI_COMMIT_REF_NAME=add-gh-linter
CI_SERVER_HOST=gitlab.com
FF_USE_DUMB_INIT_WITH_KUBERNETES_EXECUTOR=false
CI_JOB_URL=https://gitlab.com/SiliconTao-Systems/STFjord/-/jobs/12426954728
CI_JOB_TOKEN=[MASKED]
CI_JOB_STARTED_AT=2025-12-13T10:33:42Z
CI_CONCURRENT_ID=8
CI_PROJECT_DESCRIPTION=A Terraform project to build a Rocky Linux droplet in Digital Ocean.
CI_PROJECT_CLASSIFICATION_LABEL=
FF_USE_LEGACY_KUBERNETES_EXECUTION_STRATEGY=false
CI_RUNNER_REVISION=71914659
FF_KUBERNETES_HONOR_ENTRYPOINT=false
FF_CLEAN_UP_FAILED_CACHE_EXTRACT=false
CI_DEPENDENCY_PROXY_USER=gitlab-ci-token
FF_USE_DYNAMIC_TRACE_FORCE_SEND_INTERVAL=false
FF_DISABLE_UMASK_FOR_DOCKER_EXECUTOR=false
CI_PROJECT_PATH_SLUG=silicontao-systems-stfjord
CI_NODE_TOTAL=1
FF_USE_GIT_NATIVE_CLONE=false
FF_USE_ADAPTIVE_REQUEST_CONCURRENCY=true
CI_BUILDS_DIR=/builds
CI_JOB_ID=12426954728
CI_PROJECT_REPOSITORY_LANGUAGES=shell,hcl
FF_LOG_IMAGES_CONFIGURED_FOR_JOB=false
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
FF_SECRET_RESOLVING_FAILS_IF_MISSING=true
CI_PROJECT_ID=74394513
CI=true
GITLAB_CI=true
CI_JOB_IMAGE=node:latest
CI_COMMIT_BEFORE_SHA=0000000000000000000000000000000000000000
CI_PROJECT_TITLE=STFjord
CI_SERVER_VERSION_MAJOR=18
FF_USE_EXPONENTIAL_BACKOFF_STAGE_RETRY=true
CI_CONFIG_PATH=.gitlab-ci.yml
NODE_VERSION=25.2.1
FF_USE_LEGACY_GCS_CACHE_ADAPTER=false
FF_USE_FASTZIP=false
CI_COMMIT_MESSAGE_IS_TRUNCATED=false
CI_DEPENDENCY_PROXY_SERVER=gitlab.com:443
DOCKER_DRIVER=overlay2
CI_PROJECT_URL=https://gitlab.com/SiliconTao-Systems/STFjord
OLDPWD=/
_=/usr/bin/env
$ echo "npx github/super-linter"
npx github/super-linter
Cleaning up project directory and file based variables
00:00
Job succeeded
```
