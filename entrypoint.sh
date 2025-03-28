#!/bin/sh -l

set -eu

# Check if the debug mode is enabled
if [ "$INPUT_DEBUG" = true ]; then
	LFTP_DEBUG="debug 3"
	LFTP_MIRROR_VERBOSE="--verbose"
else 
	LFTP_DEBUG=""
	LFTP_MIRROR_VERBOSE=""
fi

# Check if the dry run mode is enabled
if [ "$INPUT_DRY_RUN" = true ]; then
	LFTP_DRY_RUN="--dry-run --just-print"
else 
	LFTP_DRY_RUN=""
fi

# Check if the required inputs are set
if [ "$INPUT_HOST" = "" ] && [ "$INPUT_USERNAME" = "" ]; then
	echo "Host and username is not set. Exiting..."
	exit 1
fi

if [ "$INPUT_LOCAL_DIR" = "" ] && [ "$INPUT_REMOTE_DIR" = "" ] && [ "$INPUT_SCRIPT" = "" ]; then
	echo "Local directory, remote directory, and lftp script is not set. Exiting..."
	exit 1
elif [ "$INPUT_LOCAL_DIR" != "" ] && [ "$INPUT_REMOTE_DIR" != "" ]; then
	LFTP_MIRROR="mirror $LFTP_MIRROR_VERBOSE --reverse --only-newer $LFTP_DRY_RUN $INPUT_LOCAL_DIR $INPUT_REMOTE_DIR"
else
	LFTP_MIRROR=""
fi

# Check if the lftp script is set
if [ "$INPUT_SCRIPT" != "" ]; then
	LFTP_SCRIPT=$INPUT_SCRIPT
fi

# Check ftp protocol
LFTP_PRIVATE_KEY=""
if [ "$INPUT_PROTOCOL" = "ftp" ]; then
	LFTP_PROTOCOL="ftp"
	LFTP_SSL="set ftp:ssl-allow no"
elif [ "$INPUT_PROTOCOL" = "ftps" ]; then
	LFTP_PROTOCOL="ftp"
	LFTP_SSL="
set ftp:ssl-auth tls
set ftp:ssl-allow yes
set ftp:ssl-force true
set ftp:ssl-protect-list true
set ftp:ssl-protect-data true
set ftp:ssl-protect-fxp true
"
elif [ "$INPUT_PROTOCOL" = "sftp" ]; then
	LFTP_PROTOCOL="sftp"
	LFTP_SSL="set sftp:auto-confirm yes"

	SSH_PRIVATE_KEY_FILE='../ssh-private-key'
	echo "$INPUT_SSH_PRIVATE_KEY" >$SSH_PRIVATE_KEY_FILE
	chmod 600 $SSH_PRIVATE_KEY_FILE
	LFTP_PRIVATE_KEY="set sftp:connect-program 'ssh -a -x -o StrictHostKeyChecking=no -i $SSH_PRIVATE_KEY_FILE'"
else
	echo "Protocol is not set. Exiting..."
	exit 1
fi

# Check if the port is set
if [ "$INPUT_PORT" = "" ]; then
	LFTP_PORT=""
else
	LFTP_PORT="-p $INPUT_PORT"
fi

if [ "$INPUT_VERIFY_CERT" = true ]; then
	LFTP_VERIFY_CERT="set ssl:verify-certificate yes"
else
	LFTP_VERIFY_CERT="set ssl:verify-certificate no"
fi

if [ "$INPUT_CREATE_REMOTE_DIR" = true ] && [ "$INPUT_REMOTE_DIR" != "" ]; then
	if [ "$INPUT_DRY_RUN" = true ]; then
		LFTP_CREATE_REMOTE_DIR="!echo 'mkdir -p -f $INPUT_REMOTE_DIR'"
	else
		LFTP_CREATE_REMOTE_DIR="mkdir -p -f $INPUT_REMOTE_DIR"
	fi
else
	LFTP_CREATE_REMOTE_DIR=""
fi

# Check if the timeout is set
if [ "$INPUT_TIMEOUT" = "" ]; then
	LFTP_TIMEOUT=""
else
	LFTP_TIMEOUT="set net:timeout $INPUT_TIMEOUT"
fi

if [ "$INPUT_MAX_RETRIES" = "" ]; then
	LFTP_MAX_RETRIES=""
else
	LFTP_MAX_RETRIES="set net:max-retries $INPUT_MAX_RETRIES"
fi

echo 'Uploading files to server...'

lftp <<EOS
set cmd:fail-exit true
set xfer:log 1
$LFTP_TIMEOUT
$LFTP_MAX_RETRIES
$LFTP_DEBUG
$LFTP_SSL
$LFTP_VERIFY_CERT
$LFTP_PRIVATE_KEY
open -u $INPUT_USERNAME,$INPUT_PASSWORD $LFTP_PORT $LFTP_PROTOCOL://$INPUT_HOST
$LFTP_CREATE_REMOTE_DIR
$LFTP_MIRROR
$LFTP_SCRIPT
bye
EOS

echo 'Files uploaded successfully!'

exit 0