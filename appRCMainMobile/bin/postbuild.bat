@echo off

pushd D:\web\hkshopper\site\buildScript
call "0021 BuildShopMgtRC.bat"

pushd D:\web\hkshopper\site\buildScript\shopMgtRC-mobile\
call "Run.bat"
pause