@echo off

where powershell >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Your Windows version is not compatible with our script:
    echo Please try to install PowerShell
    pause
    exit /b 1
)

setlocal EnableDelayedExpansion

where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo npm not found. Checking for Chocolatey...
    
    where choco >nul 2>nul
    if %ERRORLEVEL% neq 0 (
        echo Installing Chocolatey...
        @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
        set PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
    )
    
    echo Installing Node.js LTS...
    choco install nodejs-lts -y
    set PATH=%PATH%;%ProgramFiles%\nodejs
    refreshenv
)

where pnpm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    npm i -g pnpm
)
echo Node.js, npm and pnpm are ready!

where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Git not found. Installing Git...
    choco install git -y
    set PATH=%PATH%;%ProgramFiles%\Git\bin
    refreshenv
    echo Git is ready!
)

echo ------ Cloning BetterDiscord ------
cd "%TEMP%"
git clone --single-branch -b main https://github.com/BetterDiscord/BetterDiscord.git
echo ------------- Cloned! -------------
cd BetterDiscord
echo ------- Installing depencies -------
pnpm install
echo ---- Building to prepare inject ----
pnpm build
echo -------- Builded and ready --------

set "found=0"
set "hasStable=0"
set "hasCanary=0"
set "hasPTB=0"

echo Searching any Discord build...
if exist "%LOCALAPPDATA%\Discord" set "hasStable=1" & set /a "found+=1"
if exist "%LOCALAPPDATA%\DiscordCanary" set "hasCanary=1" & set /a "found+=1"
if exist "%LOCALAPPDATA%\DiscordPTB" set "hasPTB=1" & set /a "found+=1"

if %found% equ 0 (
    echo No Discord installation found. Please install Discord first.
    pause
    exit /b 1
)

if %found% equ 1 (
    if %hasStable% equ 1 set "dscbuild=s"
    if %hasCanary% equ 1 set "dscbuild=c"
    if %hasPTB% equ 1 set "dscbuild=p"
    goto CONTINUE
)

echo Multiple Discord installations found:
set "option=0"
if %hasStable% equ 1 (
    set /a "option+=1"
    echo !option!^) Discord Stable
)
if %hasCanary% equ 1 (
    set /a "option+=1"
    echo !option!^) Discord Canary
)
if %hasPTB% equ 1 (
    set /a "option+=1"
    echo !option!^) Discord PTB
)

:CHOICE
set /p "choice=Select Discord version (1-!option!): "
set "selected=0"
set "current=0"

if %hasStable% equ 1 (
    set /a "current+=1"
    if %choice% equ !current! set "dscbuild=s" & set "selected=1"
)
if %hasCanary% equ 1 (
    set /a "current+=1"
    if %choice% equ !current! set "dscbuild=c" & set "selected=1"
)
if %hasPTB% equ 1 (
    set /a "current+=1"
    if %choice% equ !current! set "dscbuild=p" & set "selected=1"
)

if %selected% equ 0 (
    echo Invalid selection. Please try again.
    goto CHOICE
)

:CONTINUE
if %dscbuild% equ "s" (
    pnpm inject
) else if %dscbuild% equ "c" (
    pnpm inject canary
) else if %dscbuild% equ "p" (
    pnpm inject ptb
)
cd ..
del /s /q ./BetterDiscord

echo Installed successfully!
pause
exit 0

endlocal