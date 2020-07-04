<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:dotml="http://www.martin-loetzsch.de/DOTML" 
	>
	
	<xsl:param name='cluster'>1</xsl:param>
	<xsl:param name='message-format'>label</xsl:param>
	
	<xsl:key name="tables-by-name" match="Tables/Table" use="@name"/>
	<xsl:key name="tables-by-id" match="Tables/Table" use="@tableId"/>
	<xsl:key name="columns-by-table-column-names" match='Column' use='concat(../@name, "_", @name)'/>

	<xsl:key name="views-by-id" match="Views/View" use="@viewId"/>

	<!-- Database Graphs -->
	<xsl:template match='Database[@name]' mode='include'>Yes</xsl:template>
	
	<xsl:template match='Database[@name]' mode='get-cmd-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('db_Relationships', '.cmd')"/>
	</xsl:template>
	<xsl:template match='Database[@name]' mode='get-dotml-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('db_Relationships', '.dotml')"/>
	</xsl:template>
	<xsl:template match='Database[@name]' mode='get-gv-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('db_Relationships', '.gv')"/>
	</xsl:template>
	<xsl:template match='Database[@name]' mode='get-png-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('db_Relationships', '.png')"/>
	</xsl:template>
	<xsl:template match='Database[@name]' mode='get-svg-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('db_Relationships', '.svg')"/>
	</xsl:template>

	<!-- Table Graphs -->
	<xsl:template match='Tables/Table[@name]' mode='include'>Yes</xsl:template>

	<xsl:template match='Tables/Table[@name]' mode='get-png-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('tbl_', $name, '.png')"/>
	</xsl:template>
	<xsl:template match='Tables/Table[@name]' mode='get-svg-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('tbl_', $name, '.svg')"/>
	</xsl:template>

	<!-- View Graphs -->
	<xsl:template match='Views/View[@name]' mode='include'>Yes</xsl:template>

	<xsl:template match='Views/View[@name]' mode='get-png-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('vw_', $name, '.png')"/>
	</xsl:template>
	<xsl:template match='Views/View[@name]' mode='get-svg-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('vw_', $name, '.svg')"/>
	</xsl:template>

	<xsl:template match="Database[@name]" mode='graph'>
		<xsl:param name="filename"/>
		<dotml:graph file-name="{$filename}" label="Database: {@name}" rankdir="LR" fontname="{$fontname}" fontcolor="black" fontsize="{$font-size-h1}" labelloc='t' >
			<xsl:apply-templates select='//Table' mode='record'>
				<xsl:with-param name='mode'>compact</xsl:with-param>
			</xsl:apply-templates>
			<xsl:apply-templates select='//Table/Column/Key' mode='key-reference'/>
		</dotml:graph>
	</xsl:template>
	
	<xsl:template match="Tables/Table[@name]" mode='graph'>
		<xsl:param name="filename"/>
		<dotml:graph file-name="{$filename}" label="Table: {@name}" rankdir="LR" fontname="{$fontname}" fontcolor="black" fontsize="{$font-size-h1}" labelloc='t' >
			<xsl:apply-templates select='.' mode='node'/>
			<xsl:apply-templates select='.' mode='link'/>
		</dotml:graph>
	</xsl:template>
	
	<xsl:template match='Tables/Table' mode='node'>
		<xsl:variable name='this-table' select='.'/>
		<xsl:variable name='other-tables' select="key('tables-by-id', Column/*/@tableId)"/>
		<xsl:variable name='highlight-table' select='@tableId'/>
	
		<xsl:apply-templates select='$this-table | $other-tables' mode='record'>
			<xsl:with-param name='highlight-table' select='$highlight-table'/>
		</xsl:apply-templates>
			
	</xsl:template>
	
	<xsl:template match='Tables/Table' mode='record'>
		<xsl:param name='mode'>verbose</xsl:param>
		<xsl:param name='highlight'>.</xsl:param>
		<xsl:variable name='table-id' select='@tableId'/>
		
		<xsl:variable name='color'>
			<xsl:choose>
				<xsl:when test='$table-id = $highlight'><xsl:value-of select='$focus-table-color'/></xsl:when>
				<xsl:when test='Rows/@count = 0'><xsl:value-of select='$empty-table-color'/></xsl:when>
				<xsl:otherwise><xsl:value-of select='$default-table-color'/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name='bgcolor'>
			<xsl:choose>
				<xsl:when test='Rows/@count = 0'><xsl:value-of select='$empty-table-bgcolor'/></xsl:when>
				<xsl:when test='$table-id = $highlight'><xsl:value-of select='$focus-table-bgcolor'/></xsl:when>
				<xsl:otherwise><xsl:value-of select='$default-table-bgcolor'/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<dotml:record fillcolor='{$bgcolor}' color="{$color}" style='filled'
					fontname="{$fontname}" fontsize="{$font-size-h2}" fontcolor="{$color}">
			<dotml:node id='t{$table-id}'  label='Table: {@name}' />
			<xsl:for-each select='Column'>
				<xsl:choose>
					<xsl:when test='Key'>
						<dotml:node id='c{$table-id}_{@columnId}' label='{@name} +' />
					</xsl:when>
					<xsl:when test='ForeignKey'>
						<dotml:node id='c{$table-id}_{@columnId}' label='+ {@name}' />
					</xsl:when>
					<xsl:when test='$mode="verbose"'>
						<dotml:node id='c{$table-id}_{@columnId}' label='{@name}' />
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<xsl:if test='$mode="compact"'>
				<xsl:variable name='other-columns' select='Column[not(*)]'/>
				<xsl:choose>
					<xsl:when test='count($other-columns) > 2'>
						<dotml:node id='c{$table-id}_other' label='({count($other-columns)} columns)' />
					</xsl:when>
					<xsl:when test='count($other-columns) = 0'>
						<!-- nothing -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select='$other-columns'>
							<dotml:node id='c{$table-id}_{@columnId}' label='{@name}' />
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</dotml:record>

	</xsl:template>

	<xsl:template match='Tables/Table' mode='link'>
		<xsl:apply-templates select='Column/*' mode='key-reference'/>
	</xsl:template>
	
	<xsl:template match='Tables/Table/Column/Key' mode='key-reference'>
		<xsl:variable name='key-id' select='concat("c", ../../@tableId, "_", ../@columnId)'/>
		<xsl:variable name='ref-column' select='key("columns-by-table-column-names", concat(@table, "_", @column))' />
		<xsl:variable name='ref-id' select='concat("c", $ref-column/../@tableId, "_", $ref-column/@columnId)'/>
		<dotml:edge from="{$key-id}" to="{$ref-id}" color='black' />
 	</xsl:template>

	<xsl:template match='Tables/Table/Column/ForeignKey' mode='key-reference'>
		<xsl:variable name='ref-id' select='concat("c", ../../@tableId, "_", ../@columnId)'/>
		<xsl:variable name='key-column' select='key("columns-by-table-column-names", concat(@table, "_", @column))' />
		<xsl:variable name='key-id' select='concat("c", $key-column/../@tableId, "_", $key-column/@columnId)'/>
		<dotml:edge from="{$key-id}" to="{$ref-id}" color='{$focus-color}' />
 	</xsl:template>

	<!-- Views Code-->
	<xsl:template match="Views/View[@name]" mode='graph'>
		<xsl:param name="filename"/>
		<dotml:graph file-name="{$filename}" label="View: {@name}" rankdir="LR" fontname="{$fontname}" fontcolor="black" fontsize="{$font-size-h1}" labelloc='t' >
			<xsl:apply-templates select='.' mode='node'/>
			<xsl:apply-templates select='.' mode='link'/>
		</dotml:graph>
	</xsl:template>
	
	<xsl:template match='Views/View' mode='node'>
		<xsl:variable name='this-view' select='.'/>
		<xsl:variable name='other-tables' select="key('tables-by-id', */Table/@tableId)"/>
		<xsl:variable name='other-views' select="key('views-by-id', */View/@viewId)"/>
		<xsl:variable name='other-procedures' select="key('procedures-by-id', */Procedure/@procedureId)"/>
		<xsl:variable name='other-functions' select="key('functions-by-id', */Function/@functionId)"/>
		<xsl:variable name='highlight' select='@viewId'/>
	
		<xsl:apply-templates select='$this-view | $other-tables | $other-views | $other-procedures | $other-functions' mode='record'>
			<xsl:with-param name='highlight' select='$highlight'/>
		</xsl:apply-templates>
			
	</xsl:template>

	<xsl:template name="concat-names">
		<xsl:param name="nodes" select='*'/>
		<xsl:for-each select='$nodes[@name]'>
			<xsl:if test='position() > 1'>\n</xsl:if>
			<xsl:value-of select='@name'/>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
