#!/bin/bash
# Usage: ./z-today-mail2.sh
# 引数なし
# Boss, Security, Project-A, ... などは、~/.mailrc に登録されたアドレスのエイリアス

TODAY="`date +%m%d`"
MAILDIR="/mnt/z/path/to/z-today/"

export LC_CTYPE=ja_JP.UTF-8

for PRJ in `ls $MAILDIR`
do
	echo $PRJ
	cd $MAILDIR/$PRJ
	pwd

	ls *.txt >/dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo "No such a text file."
		echo ""
	else
		echo "Text file exists."
		for mailtxt in `ls *.txt`
		do
			# メール送信
			# cat ${mailtxt}
			# mail -v　送信ログが、From あてに届く
			cat ${mailtxt} | \
			mail \
			-s ${mailtxt%.*} \
			-r z-today@abcd.com \
			-c ${PRJ}-Cc \
			${PRJ}-To

			# 移動
			mv ${mailtxt} done
		done
	fi
done
