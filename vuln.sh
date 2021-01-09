#!/bin/bash

# for...in
for html in `ls *.html`
do
	echo ターゲット：
	echo ${html}
	echo ""
	
	# 1行目の改行削除（空行削除）
	# nkf -Lu z-today1225_zip.html | sed '/^$/d' > temp.txt
	nkf -Lu ${html} | sed '/^$/d' > temp.txt
	
	# ファイル名取得
	cat temp.txt | rev | cut -c 18-32 | rev > fn.txt
	FILENAME=$(cat fn.txt)
	echo ファイル名：
	echo $FILENAME
	echo ""
	
	# URL取得
	cat temp.txt | awk '{sub("<html.*.URL=", "")};BEGIN{ORS = ""};{print $0;}' > temp2.txt
	cat temp2.txt | awk '{sub("\">.*.html>", "")};BEGIN{ORS = ""};{print $0;}' > temp3.txt
	URL=$(cat temp3.txt)
	echo URL:
	echo $URL
	echo ""
	
	# ダウンロード
	wget --no-check-certificate $URL -O $FILENAME
	
	# 解凍
	unar $FILENAME
	
	# 移動
	mv ${html} done
	mv $FILENAME done
done
