@echo off
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

goto end

@echo === Service Diagrams ===

%nxslt% Working\model.xml StyleSheets\render-services.xslt -o Working\services-simple-tb.dotml message-format=none title="Simple Services View" direction=TB
%nxslt% Working\model.xml StyleSheets\render-services.xslt -o Working\services-label-tb.dotml message-format=label title="Services View" direction=TB
%nxslt% Working\model.xml StyleSheets\render-services.xslt -o Working\services-node-tb.dotml message-format=node title="Services & Messages View" direction=TB
%nxslt% Working\model.xml StyleSheets\render-services.xslt -o Working\services-simple-lr.dotml message-format=none title="Simple Services View" direction=LR
%nxslt% Working\model.xml StyleSheets\render-services.xslt -o Working\services-label-lr.dotml message-format=label title="Services View" direction=LR
%nxslt% Working\model.xml StyleSheets\render-services.xslt -o Working\services-node-lr.dotml message-format=node title="Services & Messages View" direction=LR
%nxslt% Working\services-simple-tb.dotml %dotml%\dotml2dot.xsl -o "Working\services-simple-tb.gv" 
%nxslt% Working\services-label-tb.dotml %dotml%\dotml2dot.xsl -o "Working\services-label-tb.gv" 
%nxslt% Working\services-node-tb.dotml %dotml%\dotml2dot.xsl -o "Working\services-node-tb.gv" 
%nxslt% Working\services-simple-lr.dotml %dotml%\dotml2dot.xsl -o "Working\services-simple-lr.gv" 
%nxslt% Working\services-label-lr.dotml %dotml%\dotml2dot.xsl -o "Working\services-label-lr.gv" 
%nxslt% Working\services-node-lr.dotml %dotml%\dotml2dot.xsl -o "Working\services-node-lr.gv" 
%graphviz%\dot.exe -Tpng "Working\services-simple-tb.gv"  -o "%output%\services-top-simple.png"
%graphviz%\dot.exe -Tpng "Working\services-label-tb.gv"  -o "%output%\services-top-label.png"
%graphviz%\dot.exe -Tpng "Working\services-node-tb.gv"  -o "%output%\services-top-node.png"
%graphviz%\dot.exe -Tpng "Working\services-simple-lr.gv"  -o "%output%\services-left-simple.png"
%graphviz%\dot.exe -Tpng "Working\services-label-lr.gv"  -o "%output%\services-left-label.png"
%graphviz%\dot.exe -Tpng "Working\services-node-lr.gv"  -o "%output%\services-left-node.png"

@echo   Generated: %output%\services-top-simple.png
@echo   Generated: %output%\services-top-label.png
@echo   Generated: %output%\services-top-node.png
@echo   Generated: %output%\services-left-simple.png
@echo   Generated: %output%\services-left-label.png
@echo   Generated: %output%\services-left-node.png

@echo === Graphs ===
%xsltproc% -o Working\graph.files.xml StyleSheets\generate-graphs-dotml.xslt Working\model.xml

cd Working\Graphs
for /F "usebackq" %%i in (`dir /b *.cmd`) DO call %%i
cd ..\..

@echo === Adapter Diagrams ===

%nxslt% Working\model.xml StyleSheets\render-adapters.xslt -o Working\adapters-node-tb.dotml message-format=node title="Adapters & Messages View" direction=TB
%nxslt% Working\model.xml StyleSheets\render-adapters.xslt -o Working\adapters-node-lr.dotml message-format=node title="Adapters & Messages View" direction=LR
%nxslt% Working\model.xml StyleSheets\render-adapters.xslt -o Working\adapters-label-tb.dotml message-format=label title="Adapters View" direction=TB
%nxslt% Working\model.xml StyleSheets\render-adapters.xslt -o Working\adapters-label-lr.dotml message-format=label title="Adapters View" direction=LR
%nxslt% Working\model.xml StyleSheets\render-adapters.xslt -o Working\adapters-simple-tb.dotml message-format=none title="Simple Adapters View" direction=TB
%nxslt% Working\model.xml StyleSheets\render-adapters.xslt -o Working\adapters-simple-lr.dotml message-format=none title="Simple Adapters View" direction=LR
%nxslt% Working\adapters-node-tb.dotml %dotml%\dotml2dot.xsl -o "Working\adapters-node-tb.gv" 
%nxslt% Working\adapters-node-lr.dotml %dotml%\dotml2dot.xsl -o "Working\adapters-node-lr.gv" 
%nxslt% Working\adapters-label-tb.dotml %dotml%\dotml2dot.xsl -o "Working\adapters-label-tb.gv" 
%nxslt% Working\adapters-label-lr.dotml %dotml%\dotml2dot.xsl -o "Working\adapters-label-lr.gv" 
%nxslt% Working\adapters-simple-tb.dotml %dotml%\dotml2dot.xsl -o "Working\adapters-simple-tb.gv" 
%nxslt% Working\adapters-simple-lr.dotml %dotml%\dotml2dot.xsl -o "Working\adapters-simple-lr.gv" 
%graphviz%\dot.exe -Tpng "Working\adapters-node-tb.gv"  -o "%output%\adapters-top-node.png"
%graphviz%\dot.exe -Tpng "Working\adapters-node-lr.gv"  -o "%output%\adapters-left-node.png"
%graphviz%\dot.exe -Tpng "Working\adapters-label-tb.gv"  -o "%output%\adapters-top-label.png"
%graphviz%\dot.exe -Tpng "Working\adapters-label-lr.gv"  -o "%output%\adapters-left-label.png"
%graphviz%\dot.exe -Tpng "Working\adapters-simple-tb.gv"  -o "%output%\adapters-top-simple.png"
%graphviz%\dot.exe -Tpng "Working\adapters-simple-lr.gv"  -o "%output%\adapters-left-simple.png"

@echo   Generated: %output%\adapters-top-node.png
@echo   Generated: %output%\adapters-left-node.png
@echo   Generated: %output%\adapters-top-label.png
@echo   Generated: %output%\adapters-left-label.png
@echo   Generated: %output%\adapters-top-simple.png
@echo   Generated: %output%\adapters-left-simple.png

goto end

:Error
echo Something is not right. 
echo Please check that these exist
echo Model=%model%
echo OutputDir=%output%
pause

:end
rem pause