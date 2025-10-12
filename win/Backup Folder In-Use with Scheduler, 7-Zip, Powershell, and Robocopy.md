Already used max known for me compression, but can have many improvements

# Step 1: Install 7-Zip

The first step is to download and install 7-Zip from their official website.

# Step 2: Run a PowerShell Script with this arguments

Create a PowerShell script that will create a backup of the folder that is in-use. Here's an example:

```
-ExecutionPolicy Bypass -NoProfile -Command "& {robocopy Builds 'Builds Backups/Temp' /z /s /e /mir /r:5 /w:5 /mt:8 /copy:DT /b /xd *Logs*; & 'C:\Program Files\7-Zip\7z.exe' a -t7z -mx=9 -mfb=273 -ms -md=31 -myx=9 -mtm=- -mmt -mmtf -md=1536m -mmf=bt3 -mmc=10000 -mpb=0 -mlc=0 -r ('.\Builds Backups\Builds_{0:ddMMyyyy}.7z' -f (Get-Date)) 'C:\Server\Builds Backups\Temp\*'; Remove-Item -Recurse -Force 'C:\Server\Builds Backups\Temp';}"
```

This script will zip the folder and store it in the Backup folder.

## Step 3: Create a Scheduled Task

Next, create a scheduled task that will run the PowerShell script at a specified time. Follow these steps:

1. Open Task Scheduler.
2. Click on "Create Task".
3. Name the task and select the option to "Run whether user is logged on or not".
4. In the "Triggers" tab, select the time when you want the backup to run.
5. In the "Actions" tab, click on "New" and select "Start a program".
6. In "Program/script", enter "powershell.exe".
7. In "Add arguments", enter the path for the PowerShell script you created in Step 3.
8. Click "OK" to save the task.
