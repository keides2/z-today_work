@echo off
:findnocpe
rem %1 Input file
rem %2 Output file
rem %3 \path\to\nocpe.txt

echo In the file %1:
echo In the file %1:>%2
echo Search for the following strings in the file "nocpe.txt" using a regular expression.
echo Search for the following strings in the file "nocpe.txt" using a regular expression.>>%2
echo.
echo. >>%2

set FILE=%1

setlocal enabledelayedexpansion
for /f "tokens=* delims= " %%l in (%3) do (
	set NOCPE=%%l

	for /f "usebackq tokens=* delims= " %%c in (`findstr /r /i /c:"!NOCPE!" %FILE%`) do (
		echo Key: "!NOCPE!"
		echo Key: "!NOCPE!">>%2
		echo Hit:
		echo Hit:>>%2
		
		set LINE=%%c
		echo !LINE!
		echo !LINE!>>%2
		echo.
		echo. >>%2
	)
)

rem Shift-JIS, CRLF ‚ð UTF-8, LF ‚É•ÏŠ·
nkf32 -wLu --overwrite %2

endlocal
exit /b
