@echo off

pushd D:\web\hkshopper\site\buildScript
call "0020 BuildShopMgt.bat"

pushd D:\web\hkshopper\site\buildScript\shopMgt-pc\
call "Run.bat"
pause