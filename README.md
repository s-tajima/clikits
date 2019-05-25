# awskits

## Prepare

### .aws/credentials

```
[source_profile_name]
aws_access_key_id=AKIXXXXXXXXXXXXXXXXX
aws_secret_access_key=9kZXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### .aws/config

```
[profile role_name]
region = ap-northeast-1
source_profile = source_profile_name
role_arn = arn:aws:iam::000000000000:role/role_name
mfa_serial = arn:aws:iam::999999999999:mfa/source_profile_name
```

## Run

```
$ bundle exec bin/list_instances [ROLE_NAME] [TOKEN_CODE]
```

