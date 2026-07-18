@echo off
setlocal enabledelayedexpansion

:: Check if a submodule path was provided
if "%~1"=="" (
    echo [ERROR] Please provide the path to the submodule.
    echo Usage: %~nx0 path/to/submodule
    exit /b 1
)

:: Normalize slashes to forward slashes for Git commands
set "SUBMODULE_PATH=%~1"
set "GIT_PATH=!SUBMODULE_PATH:\=/!"

echo [1/4] Unregistering submodule from local git config...
git submodule deinit -f "!GIT_PATH!"
if %errorlevel% neq 0 (
    echo [WARNING] Submodule deinit failed or it was already unregistered. Proceeding...
)

echo [2/4] Removing submodule from index and tracking...
git rm -f "!GIT_PATH!"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to run 'git rm'. Verify the path is correct.
    exit /b %errorlevel%
)

echo [3/4] Deleting hidden cached internal directory...
:: Windows needs backslashes for native file system deletion
set "WIN_PATH=!SUBMODULE_PATH:/=\!"
if exist ".git\modules\!WIN_PATH!" (
    rmdir /s /q ".git\modules\!WIN_PATH!"
    echo Hidden cache cleared successfully.
) else (
    echo [INFO] Hidden cache folder '.git/modules/!GIT_PATH!' not found. Skipping...
)

echo [4/4] Committing changes...
git commit -m "Remove submodule !GIT_PATH!"

echo.
echo [SUCCESS] Submodule '!GIT_PATH!' has been completely removed.
endlocal
