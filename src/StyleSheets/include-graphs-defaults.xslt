<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:dotml="http://www.martin-loetzsch.de/DOTML" 
	>
	
	
	
	<!-- Default filenames -->
	<xsl:template match='*[@name]' mode='get-dotml-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat($name, '.dotml')"/>
	</xsl:template>

	<xsl:template match='*[@name]' mode='get-gv-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat($name, '.gv')"/>
	</xsl:template>

	<xsl:template match='*[@name]' mode='get-png-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat($name, '.png')"/>
	</xsl:template>

	<xsl:template match='*[@name]' mode='get-svg-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat($name, '.svg')"/>
	</xsl:template>

	
	<xsl:template match='*[@name]' mode='get-cmd-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat($name, '.cmd')"/>
	</xsl:template>
	
	<!-- default template to include files -->
	<xsl:template match='*[@name]' mode='include'>
		<!-- Return 'Yes' to include this item as a graph --> 
	</xsl:template>

	<!-- default graph type-->
	<xsl:template match='*[@name]' mode='graph-type'>dot</xsl:template>
	<!-- default graph options-->
	<xsl:template match='*[@name]' mode='graph-options'></xsl:template>
	
	<!-- Default template that will output a simple error diagram -->
	<xsl:template match='*[@name]' mode='graph'>
		<xsl:param name='filename'/>
		<dotml:graph file-name="{$filename}" label="{@name}" rankdir="LR" fontname="Arial" fontsize="12.0" size="8,8">
			<dotml:cluster id="cluster" label="Errors" style='dotted' color='{$red-color}' fontcolor='{$red-color}'>
				<dotml:node id="error" label="{concat($quote, @name, $quote, ' does not have a dotml graph template.')}" shape='box' color='{$red-color}' fontcolor='{$red-color}'/>
			</dotml:cluster>
		</dotml:graph>
	</xsl:template>

</xsl:stylesheet>
