@echo off
echo.
echo ================================================
echo   EF-BLIPS MLO INTEGRATION SCRIPT
echo   Los Scotia Server - MLO Blips Installer
echo ================================================
echo.

set "EFBLIPS_PATH=a:\Gaming\Gta FiveM\Server List\Los Scotia\txData\QBCore_BCE182.base\resources\[maps]\ef-blips"
set "SOURCE_PATH=a:\Gaming\Gta FiveM\Server List\Los Scotia\txData\QBCore_BCE182.base\resources\[standalone]\ls-scripts"

echo [1/3] Copying MLO blips configuration to ef-blips...
copy "%SOURCE_PATH%\ef-blips-mlo-config.lua" "%EFBLIPS_PATH%\mlo-blips.lua"

echo [2/3] Copying integration guide...
copy "%SOURCE_PATH%\ef-blips-integration-guide.lua" "%EFBLIPS_PATH%\integration-guide.lua"

echo [3/3] Creating backup of original config...
if exist "%EFBLIPS_PATH%\config.lua" (
    copy "%EFBLIPS_PATH%\config.lua" "%EFBLIPS_PATH%\config.lua.backup"
    echo Backup created: config.lua.backup
)

echo.
echo ================================================
echo   INSTALLATION COMPLETE!
echo ================================================
echo.
echo NEXT STEPS:
echo 1. Open ef-blips\config.lua
echo 2. Add this line to include MLO blips:
echo    require 'mlo-blips'
echo.
echo 3. Or manually copy the blips from mlo-blips.lua
echo    to your existing config.lua file
echo.
echo 4. Restart ef-blips resource:
echo    restart ef-blips
echo.
echo FILES CREATED:
echo - ef-blips\mlo-blips.lua (70+ MLO blips)
echo - ef-blips\integration-guide.lua (instructions)
echo - ef-blips\config.lua.backup (if config existed)
echo.
echo All MLO blips are ready to be added to your server!
echo.
pause