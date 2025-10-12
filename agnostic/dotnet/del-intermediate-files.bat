@ECHO off
cls

ECHO Deleting all BIN and OBJ folders...
ECHO.

cd ../
cd src/

FOR /d /r . %%d in (*) DO (
	IF EXIST "%%d\bin" (
		ECHO %%d | FIND /I "\node_modules\" > Nul && ( 
			ECHO Skipping: %%d\bin
		) || (
			ECHO Deleting: %%d\bin
			rd /s/q "%%d\bin"
		)
	)

	IF EXIST "%%d\obj" (
		ECHO %%d | FIND /I "\node_modules\" > Nul && ( 
			ECHO Skipping: %%d\obj
		) || (
			ECHO Deleting: %%d\obj
			rd /s/q "%%d\obj"
		)
	)
)

ECHO.
ECHO BIN, OBJ folders have been successfully deleted. Press any key to exit.
pause > nul
