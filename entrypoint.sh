#!/bin/sh -l

#set -eux

# Check if the required inputs are set
if [ "$INPUT_HOST" = "" ] && [ "$INPUT_USERNAME" = "" ]; then
	echo "Host and username is not set. Exiting..."
	exit 1
fi

if [ "$INPUT_LOCAL_DIR" = "" ] && [ "$INPUT_REMOTE_DIR" = "" ]; then
	if [ "$INPUT_SCRIPT" = "" ]; then
		echo "Local directory, remote directory, and lftp script is not set. Exiting..."
		exit 1
	else
		LFTP_SCRIPT=$INPUT_SCRIPT
	fi
	LFTP_LOCAL_DIR=""
	LFTP_REMOTE_DIR=""
else
	LFTP_LOCAL_DIR=$INPUT_LOCAL_DIR
	LFTP_REMOTE_DIR=$INPUT_REMOTE_DIR
	if [ "$INPUT_SCRIPT" != "" ]; then
		LFTP_SCRIPT=$INPUT_SCRIPT
	fi
fi

# Check ftp protocol
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
	LFTP_SSL="
set ftp:ssl-allow no
set sftp:auto-confirm no
"
else
	echo "Protocol is not set. Exiting..."
	exit 1
fi


# Check if the debug mode is enabled
if [ "$INPUT_DEBUG" = true ]; then
	LFTP_DEBUG="debug 9"
else 
	LFTP_DEBUG=""
fi

# Check if the dry run mode is enabled
if [ "$INPUT_DRY_RUN" = true ]; then
	LFTP_DRY_RUN="--dry-run --just-print"
else 
	LFTP_DRY_RUN=""
fi

echo 'Uploading files to server...'

# LFTP_SCRIPT=''
# echo 'TEST' >> $LFTP_SCRIPT

# echo $LFTP_SCRIPT

#set sftp:connect-program 'ssh -a -x -o StrictHostKeyChecking=no -i $TEMP_SSH_PRIVATE_KEY_FILE'
#open sftp://$FTP_USERNAME:dummy@$FTP_SERVER

ssh -a -x -o StrictHostKeyChecking=no $INPUT_USERNAME@$INPUT_HOST touch /public_html/test.txt

# lftp <<EOS
# # set cmd:fail-exit true
# # set xfer:log 1
# $LFTP_DEBUG
# #$LFTP_SSL
# set sftp:connect-program 'ssh -a -x -o StrictHostKeyChecking=no'
# open -u $INPUT_USERNAME,$INPUT_PASSWORD $LFTP_PROTOCOL://$INPUT_HOST
# #user $INPUT_USERNAME $INPUT_PASSWORD
# #mirror --reverse --overwrite $LFTP_DRY_RUN $LFTP_LOCAL_DIR $LFTP_REMOTE_DIR
# $LFTP_SCRIPT
# #close
# #exit
# EOS

echo 'Files uploaded successfully!'

exit 0