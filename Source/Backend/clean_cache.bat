@echo off
title Clean Visual Studio Project
echo =====================================
echo Deleting bin, obj, .vs, *.csproj.user
echo =====================================
echo.

:: Xóa thư mục bin
for /d /r %%d in (bin) do (
    if exist "%%d" (
        echo Deleting: %%d
        rd /s /q "%%d"
    )
)

:: Xóa thư mục obj
for /d /r %%d in (obj) do (
    if exist "%%d" (
        echo Deleting: %%d
        rd /s /q "%%d"
    )
)

:: Xóa thư mục .vs
for /d /r %%d in (.vs) do (
    if exist "%%d" (
        echo Deleting: %%d
        rd /s /q "%%d"
    )
)

:: Xóa file *.csproj.user
for /r %%f in (*.csproj.user) do (
    if exist "%%f" (
        echo Deleting: %%f
        del /f /q "%%f"
    )
)

echo.
echo =====================================
echo Cleanup completed!
echo =====================================
pause