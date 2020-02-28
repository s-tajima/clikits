# githubkits

## Prepare

### GitHub personal access token

1. Follow [this steps](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) and create Personal Access Token.

2. Set to Environment Variables
```
export GITHUB_ACCESS_TOKEN=xxx
```

## Commands

### Transfer a repository

```
$ bundle exec bin/transfer_repository [REPO_NAME] [NEW_ORG_NAME] [TEAM_IDS]
```

### List branch protection

```
$ bundle exec bin/list_branch_protection
```

### Enable branch protection

```
$ bundle exec bin/enable_branch_protection [REPO_NAME]
```
