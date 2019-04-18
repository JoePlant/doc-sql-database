@echo OFF
set model=%1
set output=%2

if %model%!! == !! goto Error
if %output%!! == !! goto Error

if NOT EXIST %model% goto Error
if NOT EXIST %output% goto Error

if EXIST Working goto Working_exists
mkdir Working
mkdir Working\Graphs
:Working_exists

if EXIST %output%\Graphs goto graphs_exists
mkdir %output%\Graphs
:graphs_exists

echo Generating...
echo   Model=%model%
echo   OutputDir=%output% 

del Working\Graphs\*.* /Q
del %output%\Graphs\*.* /Q

set nxslt=..\lib\nxslt\nxslt.exe
set graphviz=..\lib\GraphViz-2.30.1\bin
set dotml=..\lib\dotml-1.4
set xsltproc=..\lib\libxml\bin\xsltproc.exe 

set bootstrap=..\lib\bootstrap 3.3.5
set jquery=..\lib\jquery 1.11.3

xcopy "%bootstrap%" %output%\lib\bootstrap /E /Y /I
xcopy "%jquery%" %output%\lib\jquery /E /Y /I
xcopy "css" %output%\css /E /Y /I

@echo === Model ===
@echo Model = %model%
%nxslt% %model% StyleSheets\generate-model.xslt -o Working\model.xml 

@echo === HTML Pages ===
%nxslt% Working\model.xml StyleSheets\render-html.xslt -o "%output%\index.html" 
@echo   Generated: %output%\index.html

@echo === Excel Files ===
%nxslt% Working\model.xml StyleSheets\excel-schema.xslt -o "%output%\schema.xls" 
@echo   Generated: %output%\schema.xls


@echo === Graphs ===
%xsltproc% -o Working\graph.files.xml StyleSheets\generate-graphs-dotml.xslt Working\model.xml

cd Working\Graphs
for /F "usebackq" %%i in (`dir /b *.cmd`) DO call %%i
cd ..\..

@echo === Publish Graphs ===
xcopy "Working\Graphs\*.png" %output%\Graphs /E /Y /I
xcopy "Working\Graphs\*.svg" %output%\Graphs /E /Y /I

goto end

:Error
echo Something is not right. 
echo Please check that these exist
echo Model=%model%
echo OutputDir=%output%
pause

:end
rem pause