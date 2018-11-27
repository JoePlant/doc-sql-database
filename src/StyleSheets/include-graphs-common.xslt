<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
				xmlns:dotml="http://www.martin-loetzsch.de/DOTML" 
				xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"				
				>

	<xsl:output method="xml" indent="yes"/>
	
	<xsl:variable name="path-nxslt"      >..\..\..\lib\nxslt\nxslt.exe </xsl:variable>
<!--	<xsl:variable name="path-graphviz"   >..\..\..\lib\GraphViz-2.30.1\bin\</xsl:variable>  -->
	<xsl:variable name="path-graphviz"   >D:\GitHub\JoePlant\graphviz-2.38\bin\</xsl:variable>
	<xsl:variable name="graphviz-png"> -Tpng </xsl:variable>
	<xsl:variable name="graphviz-svg"> -Tsvg </xsl:variable>
	<xsl:variable name="path-dotml"      >..\..\..\lib\dotml-1.4\dotml2dot.xsl </xsl:variable>
	<xsl:variable name="path-png"		 >.\</xsl:variable>
	<xsl:variable name="path-svg"		 >.\</xsl:variable>

	<xsl:variable name="crlf" select="'&#xD;&#xA;'"/>
	<xsl:variable name="quote">'</xsl:variable>
	<xsl:variable name="dquote">"</xsl:variable>
	
	<xsl:include href='include-graphs-colours.xslt'/>
		
	<!--
		%nxslt% Working\metrics.dotml %dotml%\dotml2dot.xsl -o Working\metrics.gv
		%graphviz%\dot.exe -Tpng Working\metrics.gv -o Output\Project.Metrics.png
	-->
	<xsl:template name="output-cmd">
		<xsl:param name="dotml-filename"><xsl:apply-templates select='.' mode='get-dotml-filename'/></xsl:param>
		<xsl:param name="gv-filename"><xsl:apply-templates select='.' mode='get-gv-filename'/></xsl:param>
		<xsl:param name="png-filename"><xsl:apply-templates select='.' mode='get-png-filename'/></xsl:param>
		<xsl:param name="svg-filename"><xsl:apply-templates select='.' mode='get-svg-filename'/></xsl:param>
		<xsl:param name="cmd-filename"><xsl:apply-templates select='.' mode='get-cmd-filename'/></xsl:param>
		<xsl:variable name="graphviz-png-command">
			<xsl:value-of select='$path-graphviz' />
			<xsl:apply-templates select='.' mode='graph-type'/><xsl:text>.exe</xsl:text>
			<xsl:value-of select='$graphviz-png'/><xsl:text> </xsl:text>
			<xsl:apply-templates select='.' mode='graph-options'/>
		</xsl:variable>
		<xsl:variable name="graphviz-svg-command">
			<xsl:value-of select='$path-graphviz' />
			<xsl:apply-templates select='.' mode='graph-type'/><xsl:text>.exe</xsl:text>
			<xsl:value-of select='$graphviz-svg'/><xsl:text> </xsl:text>
			<xsl:apply-templates select='.' mode='graph-options'/>
		</xsl:variable>
		<xsl:variable name='command'>
			<xsl:text>@echo Drawing - </xsl:text><xsl:value-of select='name()'/> - <xsl:value-of select='@name'/>
			<xsl:value-of select='$crlf'/>
			<xsl:text>REM Convert "</xsl:text><xsl:value-of select="$dotml-filename"/>" to "<xsl:value-of select="concat($path-png, $png-filename)"/><xsl:text>"</xsl:text>
			<xsl:value-of select="concat($crlf, $path-nxslt, $dotml-filename, ' ', $path-dotml, ' -o ', $gv-filename)" /> 
			<xsl:value-of select="concat($crlf, $graphviz-png-command, $gv-filename, ' ', ' -o ', $dquote, $path-png, $png-filename, $dquote)" /> 
			<xsl:value-of select="concat($crlf, $graphviz-svg-command, $gv-filename, ' ', ' -o ', $dquote, $path-svg, $svg-filename, $dquote)" /> 
		</xsl:variable>
		<exsl:document href="{concat('Graphs\', $cmd-filename)}" method="text" >
			<xsl:value-of select='$command'/>
		</exsl:document>
		<Graph input='{$dotml-filename}' png-output='{concat($path-png, $png-filename)}' svg-output='{concat($path-png, $png-filename)}'>
			<xsl:value-of select='$command'/>
		</Graph>
	</xsl:template>
	
	<xsl:template name='escape-label'>
		<xsl:param name='label'/>
		<xsl:value-of select="translate($label, concat('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz _\', $quote, $dquote), 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz _/')"/>
	</xsl:template>
		
</xsl:stylesheet>
