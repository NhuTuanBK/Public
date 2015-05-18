ECHO OFF
::config variable
call:configFunction

::checkout
call:checkoutFunction

::delete file hidden
call:delHiddenFileFunction

::zip %SVN_LOCATION_ZIP%%SVN_NAME_ZIP%
call:zipFunction

::copy other server
::call:copyToServerFunction

::complete success
call:sendEmailFunction "complete success"
call:cleanCompleteFunction
pause
exit

:configFunction
set FILE_URL=%~dp0
FOR /F "tokens=1 delims=;" %%G IN (%FILE_URL%configCronJob.txt) DO set %%G
 ::C:\ServiceUpdate\configCronJob.txt
goto:eof

:checkoutFunction
echo start checkout
svn checkout --username %SVN_USERNAME% --password %SVN_PASS% %SVN_URL% %SVN_LOCATION%
::svn checkout --quiet --username %SVN_USERNAME% --password %SVN_PASS% %SVN_URL% %SVN_LOCATION%
echo end checkout
if %ERRORLEVEL% EQU 0 goto:eof
call:sendEmailFunction " checkout errorlevel:%ERRORLEVEL%"
exit

:delHiddenFileFunction
echo start delete all file hidden
RD /S /Q %SVN_LOCATION%\.svn
cd %FILE_URL%
::FOR /F "tokens=*" %G IN ('DIR /B /AD /S .svn') DO RMDIR /S /Q "%G"
::del /q /s  .svn
::/S-del sub folder; /Q ignore confirm (Y/N)
echo end delete
if %ERRORLEVEL% EQU 0 goto goto:eof
call:sendEmailFunction "delete file hidden errorlevel:%ERRORLEVEL%"
exit

:zipFunction
echo start zip
for /f "tokens=2" %%a in ("%DATE%") do set nameDate=%%a
for /f "tokens=1-3 delims=/ " %%a in ("%nameDate%") do set nameDate=%%a_%%b_%%c
for /f "tokens=1-2 delims=: " %%a in ("%TIME%") do set nameTime=%%a_%%b

::zip -r %FILE_URL%%SVN_NAME_ZIP%__%nameDate%__%nameTime%.zip %SVN_LOCATION%
"C:\Program Files\WinRAR"\rar a -r %FILE_URL%%SVN_NAME_ZIP%__%nameDate%__%nameTime%.zip %SVN_LOCATION%
echo end zip
if %ERRORLEVEL% EQU 0 goto:eof
call:sendEmailFunction "zip file errorlevel:%ERRORLEVEL%"
exit

:copyToServerFunction
call:connectLanFunction
call:copyFunction
goto:eof

:connectLanFunction
echo connect lan...
net use %FIS_SAVE%
	:: mypassword /user:Administrator
echo connected
if %ERRORLEVEL% EQU 0 goto:eof
call:sendEmailFunction "connect FIS_SAVE errorlevel:%ERRORLEVEL%"
exit

::start copy
:START_COPY_ZIP_LABLE
:copyFunction
echo coping file ...
copy %FILE_URL%%SVN_NAME_ZIP%__%nameDate%__%nameTime%.zip %FIS_SAVE%
if %ERRORLEVEL% EQU 0 goto:eof
call:sendEmailFunction "copy zip errorlevel:%ERRORLEVEL%"
exit

:sendEmailFunction
FOR /F "tokens=1 delims=;" %%G IN (%~dp0\configMail.txt) DO set %%G
set MESSAGE="%~1"
java -jar %~dp0\SendEmail.jar  %FROM_EMAIL%  %PASS%  %TO_EMAIL%  %SUBJECT% %MESSAGE%
pause
goto:eof

:cleanCompleteFunction
	::delete folder SVN
echo delete folder svn location
RD /S /Q %SVN_LOCATION%

if %ERRORLEVEL% EQU 0 goto COPY_ZIP_LABLE
call:sendEmailFunction "complete: delete folder errorlevel:%ERRORLEVEL%"
goto:eof