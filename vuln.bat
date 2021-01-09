@echo off
REM 前提条件：Zドライブとして”\\xxx.xxx.xxx.xxx\path\to\z”をマウントしておくこと
REM 検索結果の保存先フォルダー
set DEST="Z:\path\to\z-today\"

setlocal EnableDelayedExpansion
REM これはVBAから呼ばれるバッチファイル。Windowsコマンドプロンプトのみで実行
REM 引数１（%1）は、実行環境

REM 実行環境決め打ちの場合
REM cd C:\Users\username\Desktop\attachments

REM 実行環境を引数でもらう
echo 引数： %1
cd %1

REM 西暦取得
set YR=%DATE:~,4%
echo YR=%YR%

REM htmlファイル名取得
for %%h in (*.html) do (
	echo ファイル名: %%h
	set FN=%%h
	set DL=!FN:~0,11!.zip
	echo FN,DL: !FN!,!DL!
	
	REM URL取得
	for /f "delims=" %%a in (!FN!) do (
		set line=%%a
		REM	echo line=!line!
		REM	echo.
		set URL=!line:~128,195!
		set URL=!URL!
		echo.

		REM ダウンロード
		echo Downloading zip-files...Cloud Proxy OFF
		echo.

		REM instr(x, y) 呼び出し
		set x=!URL!
		set y=^"

		REM 記号 >< 削除
		set x=!x:^>=!
		set x=!x:^<=!
		REM echo x=!x!
		REM echo.

		call :instr
		REM echo returned r=!r!
		REM echo returned URL=!x!
		REM	echo.
		REM ▼(set z=!x:~%r%,1!)できて、(set URL=!URL:~0,%r%!)できない?
		REM (set URL2=!URL:~1,%r%!)

		set SCRIPT=Invoke-WebRequest -Uri "!x!" -OutFile "!DL!"
		echo SCRIPT=!SCRIPT!
		REM Invoke-WebRequestのエイリアスがwgetなので↓でも可
		REM wget http://IpAddress/resource -OutFile out.html

		powershell.exe -NoProfile -ExecutionPolicy Unrestricted -command "!SCRIPT!"
		REM echo ErrorLevel=!ERRORLEVEL!

		REM 解凍
		echo Extracting files...
		REM "C:\Program Files\7-Zip\7z.exe" x %DL%

		REM zipファイルを解凍
		REM コマンドプロンプトからPowerShellを呼んでいるけど、標準で解凍する方法がこれしかないので仕方ない...
		powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('!DL!', '.'); }"
		
		REM プロジェクト名取得
		for /f "usebackq tokens=*" %%p in (`dir /b .\proj`) do (
			echo.
			echo %%p

			REM 複数プロジェクト対応
			set PRJ=%%p
			set WRK=.\proj\!PRJ!
			set NOCPE=!WRK!\nocpe.txt
			echo 'nocpe.txt' に記載したCPEリストにないソフトウェアを検索する
			REM set FN=z-today0403_zip.html
			REM set DL=z-today0328.zip
			
			set MT=!FN:~7,2!
			set DT=!FN:~9,2!
			set Z-TODAY=!FN:~0,11!
			set INFN=.\!Z-TODAY!\脆弱性TODAY_data2020-!MT!-!DT!.csv
			echo !INFN!

			set FNDATE=!FN:~7,4!
			echo FNDATE=!FNDATE!
			
			REM set OUTFN=[!PRJ!]NoCPE-!FN:~0,11!.txt
			set OUTFN=[!PRJ!]NoCPE-!FN:~0,7!%YR%!FNDATE!.txt
			echo OUTFN=!OUTFN!
			
			call findnocpe2.bat !INFN! !OUTFN! !NOCPE!
			copy !OUTFN! %DEST%!PRJ!
			move /Y !OUTFN! !WRK!
			echo.
		)

		REM ファイル移動
		echo Moving files...
		move /Y !FN! done
		move /Y !DL! done
		echo.
	)
)

endlocal
echo Done!
exit


REM サブルーチン
REM r=len(x)
:len
set /a r=0

:len2
(set z=!x:~%r%,1!)
if not defined z goto :eof
set /a r+=1
REM echo r=!r!
goto :len2

REM r=instr(x,y)
:instr
setlocal enabledelayedexpansion
echo --- instr ---
REM echo x=!x!
REM echo y=!y!

REM 全長を求める
REM xxにxを退避
set xx=!x!
call :len
set /a xlen=r
REM echo xlen=!xlen!

REM マーカー文字の長さを求める
set x=!y!
call :len
set /a ylen=r
REM echo ylen=!ylen!

REM マーカー文字から最後までの長さを求める
REM echo xx=!xx!
set x=!xx:*%y%=!
REM echo x=!x!
call :len
set /a zlen=r
REM echo zlen=!zlen!
REM ▼ set x=!xx:*%y%=! できて、set x=!xx:%y%.*=! できない
REM set x=!xx:%y%.*=!
set x=!xx:%y%%x%=!
echo Newx=!x!
echo.

if !zlen!==!xlen! (set /a r=0) else (
	set /a r=xlen - ylen - zlen + 1
	)
echo instr return with value
endlocal & (
	set /a r=%r%-1
	set x=%x%
	)
exit /b
