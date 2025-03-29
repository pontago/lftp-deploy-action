# FTP Deploy Action via lftp (FTP, SFTP, FTPS)

<!-- action-docs-description source="action.yml" -->

Supports FTP, FTPS, SFTP. and lftp commands.

<!-- action-docs-description source="action.yml" -->

⚡️Direct use to lftp commands⚡️

## Features

- Supports FTP, FTPS, SFTP protocols
- SSH private key for authentication (SFTP)
- lftp script commands
- Upload select local directory to remote
- Create remote directory if it doesn't exist

## Usage

### Simple Example

Sync local directory to remote directory with use SFTP protocol and SSH private key.

```yaml
on: push

jobs:
  deploy:
    name: Checkout and Upload
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Upload Files
        uses: pontago/lftp-deploy-action@master
        with:
          protocol: sftp
          host: example.com
          username: username
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          local_dir: ./local/
          remote_dir: /home/user1/remote/
```

### lftp commands Example

Move, create, upload, and change permissions on directories.

Read more lftp commands https://lftp.yar.ru/lftp-man.html

```yaml
on: push

jobs:
  deploy:
    name: Checkout and Upload
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Upload Files
        uses: pontago/lftp-deploy-action@master
        with:
          protocol: sftp
          host: example.com
          username: username
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            mv /home/user1/remote /home/user1/remote_bak
            mkdir -p /home/user1/remote
            mirror --verbose --reverse ./local/ /home/user1/remote/
            mkdir -p /home/user1/logs
            chmod 600 /home/user1/logs
```

<!-- action-docs-inputs source="action.yml" -->

## Inputs

| name                | description                                                                                                                   | required | default |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| `host`              | <p>Sever Hostname or IP</p>                                                                                                   | `true`   | `""`    |
| `username`          | <p>Login Username</p>                                                                                                         | `true`   | `""`    |
| `password`          | <p>Login Password</p>                                                                                                         | `false`  | `""`    |
| `port`              | <p>Default port are FTP(21), SFTP(22).</p>                                                                                    | `false`  | `""`    |
| `protocol`          | <p>Transfer protocol (ftp, ftps, sftp)</p>                                                                                    | `false`  | `ftp`   |
| `ssh_private_key`   | <p>If you want to use SSH Private Key, protocol parameter should be sftp.</p>                                                 | `false`  | `""`    |
| `verify_cert`       | <p>If you want to no SSL verification, false. (FTPS)</p>                                                                      | `false`  | `true`  |
| `local_dir`         | <p>Upload source directory.</p>                                                                                               | `false`  | `""`    |
| `remote_dir`        | <p>Upload remote directory.</p>                                                                                               | `false`  | `""`    |
| `create_remote_dir` | <p>If doesn't exists, create remote directory.</p>                                                                            | `false`  | `true`  |
| `script`            | <p>Support lftp commands. If you input local<em>dir and remote</em>dir, the script will be executed after mirror command.</p> | `false`  | `""`    |
| `dry_run`           | <p>You can check the operation. Not upload and create remote directory.</p>                                                   | `false`  | `false` |
| `debug`             | <p>Debug mode. Output lftp log and upload verbose.</p>                                                                        | `false`  | `false` |
| `timeout`           | <p>Timeout in seconds.</p>                                                                                                    | `false`  | `30`    |
| `max_retries`       | <p>Max retries. 0 is unlimited. 1 means no retries.</p>                                                                       | `false`  | `5`     |

<!-- action-docs-inputs source="action.yml" -->

## Notes

- If want to use SSH private key, save to actions secrets for your repository.
- If you input local<em>dir and remote</em>dir, the script will be executed after mirror command.
- The following command will be executed when local_dir and remote_dir are inputed.

```sh
mirror --reverse --only-newer local_dir remote_dir
```
