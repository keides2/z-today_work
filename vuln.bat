@echo off
REM �O������FZ�h���C�u�Ƃ��āh\\xxx.xxx.xxx.xxx\path\to\z�h���}�E���g���Ă�������
REM �������ʂ̕ۑ���t�H���_�[
set DEST="Z:\path\to\z-today\"

setlocal EnableDelayedExpansion
REM �����VBA����Ă΂��o�b�`�t�@�C���BWindows�R�}���h�v�����v�g�݂̂Ŏ��s
REM �����P�i%1�j�́A���s��

REM ���s�����ߑł��̏ꍇ
REM cd C:\Users\username\Desktop\attachments

REM ���s���������ł��炤
echo �����F %1
cd %1

REM ����擾
set YR=%DATE:~,4%
echo YR=%YR%

REM html�t�@�C�����擾
for %%h in (*.html) do (
	echo �t�@�C����: %%h
	set FN=%%h
	set DL=!FN:~0,11!.zip
	echo FN,DL: !FN!,!DL!
	
	REM URL�擾
	for /f "delims=" %%a in (!FN!) do (
		set line=%%a
		REM	echo line=!line!
		REM	echo.
		set URL=!line:~128,195!
		set URL=!URL!
		echo.

		REM �_�E�����[�h
		echo Downloading zip-files...Cloud Proxy OFF
		echo.

		REM instr(x, y) �Ăяo��
		set x=!URL!
		set y=^"

		REM �L�� >< �폜
		set x=!x:^>=!
		set x=!x:^<=!
		REM echo x=!x!
		REM echo.

		call :instr
		REM echo returned r=!r!
		REM echo returned URL=!x!
		REM	echo.
		REM ��(set z=!x:~%r%,1!)�ł��āA(set URL=!URL:~0,%r%!)�ł��Ȃ�?
		REM (set URL2=!URL:~1,%r%!)

		set SCRIPT=Invoke-WebRequest -Uri "!x!" -OutFile "!DL!"
		echo SCRIPT=!SCRIPT!
		REM Invoke-WebRequest�̃G�C���A�X��wget�Ȃ̂Ł��ł���
		REM wget http://IpAddress/resource -OutFile out.html

		powershell.exe -NoProfile -ExecutionPolicy Unrestricted -command "!SCRIPT!"
		REM echo ErrorLevel=!ERRORLEVEL!

		REM ��
		echo Extracting files...
		REM "C:\Program Files\7-Zip\7z.exe" x %DL%

		REM zip�t�@�C������
		REM �R�}���h�v�����v�g����PowerShell���Ă�ł��邯�ǁA�W���ŉ𓀂�����@�����ꂵ���Ȃ��̂Ŏd���Ȃ�...
		powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('!DL!', '.'); }"
		
		REM �v���W�F�N�g���擾
		for /f "usebackq tokens=*" %%p in (`dir /b .\proj`) do (
			echo.
			echo %%p

			REM �����v���W�F�N�g�Ή�
			set PRJ=%%p
			set WRK=.\proj\!PRJ!
			set NOCPE=!WRK!\nocpe.txt
			echo 'nocpe.txt' �ɋL�ڂ���CPE���X�g�ɂȂ��\�t�g�E�F�A����������
			REM set FN=z-today0403_zip.html
			REM set DL=z-today0328.zip
			
			set MT=!FN:~7,2!
			set DT=!FN:~9,2!
			set Z-TODAY=!FN:~0,11!
			set INFN=.\!Z-TODAY!\�Ǝ㐫TODAY_data2020-!MT!-!DT!.csv
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

		REM �t�@�C���ړ�
		echo Moving files...
		move /Y !FN! done
		move /Y !DL! done
		echo.
	)
)

endlocal
echo Done!
exit


REM �T�u���[�`��
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

REM �S�������߂�
REM xx��x��ޔ�
set xx=!x!
call :len
set /a xlen=r
REM echo xlen=!xlen!

REM �}�[�J�[�����̒��������߂�
set x=!y!
call :len
set /a ylen=r
REM echo ylen=!ylen!

REM �}�[�J�[��������Ō�܂ł̒��������߂�
REM echo xx=!xx!
set x=!xx:*%y%=!
REM echo x=!x!
call :len
set /a zlen=r
REM echo zlen=!zlen!
REM �� set x=!xx:*%y%=! �ł��āAset x=!xx:%y%.*=! �ł��Ȃ�
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
