#!/bin/bash
rsync -v -rlt -i --delete LOCAL_DIR USER@REMOTE_HOST:~/remote_dir/

