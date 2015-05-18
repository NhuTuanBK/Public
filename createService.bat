ECHO OFF
FOR /F "tokens=1 delims=;" %%G IN (configService.txt) DO set %%G
set TaskRun=C:\ServiceUpdate\CronJob.bat
schtasks /create /tn BackUpOBC /tr %TaskRun% /sc minute /mo %MINUTE%
PAUSE