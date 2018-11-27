<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:dotml="http://www.martin-loetzsch.de/DOTML" 
	>
	
	<xsl:param name='cluster'>1</xsl:param>
	<xsl:param name='message-format'>label</xsl:param>
	
	<xsl:key name="tables-by-name" match="Table" use="@name"/>
	<xsl:key name="tables-by-id" match="Table" use="@tableId"/>
	<xsl:key name="columns-by-table-column-names" match='Column' use='concat(../@name, "_", @name)'/>

	<xsl:template match='Database[@name]' mode='include'>Yes</xsl:template>
	
	<xsl:template match='Database[@name]' mode='get-png-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('db_', $name, '.png')"/>
	</xsl:template>
	<xsl:template match='Database[@name]' mode='get-svg-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('db_', $name, '.svg')"/>
	</xsl:template>

	<xsl:template match='Table[@name]' mode='get-png-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('tbl_', $name, '.png')"/>
	</xsl:template>
	<xsl:template match='Table[@name]' mode='get-svg-filename'>
		<xsl:param name='name' select='@name'/>
		<xsl:value-of select="concat('tbl_', $name, '.svg')"/>
	</xsl:template>
	
	<xsl:template match='Table[@name]' mode='include'>Yes</xsl:template>
	
	<xsl:template match="Database[@name]" mode='graph'>
		<xsl:param name="filename"/>
		<dotml:graph file-name="{$filename}" label="Database: {@name}" rankdir="LR" fontname="{$fontname}" fontcolor="black" fontsize="{$font-size-h1}" labelloc='t' >
			<xsl:apply-templates select='//Table' mode='record'>
				<xsl:with-param name='mode'>compact</xsl:with-param>
			</xsl:apply-templates>
			<xsl:apply-templates select='//Table/Column/Key' mode='key-reference'/>
		</dotml:graph>
	</xsl:template>
	
	<xsl:template match="Table[@name]" mode='graph'>
		<xsl:param name="filename"/>
		<dotml:graph file-name="{$filename}" label="Table: {@name}" rankdir="LR" fontname="{$fontname}" fontcolor="black" fontsize="{$font-size-h1}" labelloc='t' >
			<xsl:apply-templates select='.' mode='node'/>
			<xsl:apply-templates select='.' mode='link'/>
		</dotml:graph>
	</xsl:template>
	
	<xsl:template match='Table' mode='node'>
		<xsl:variable name='this-table' select='.'/>
		<xsl:variable name='other-tables' select="key('tables-by-id', Column/*/@tableId)"/>
		<xsl:variable name='highlight-table' select='@tableId'/>
	
		<xsl:apply-templates select='$this-table | $other-tables' mode='record'>
			<xsl:with-param name='highlight-table' select='$highlight-table'/>
		</xsl:apply-templates>
			
	</xsl:template>
	
	<xsl:template match='Table' mode='record'>
		<xsl:param name='mode'>verbose</xsl:param>
		<xsl:param name='highlight-table'>.</xsl:param>
		<xsl:variable name='table-id' select='@tableId'/>
		
		<xsl:variable name='color'>
			<xsl:choose>
				<xsl:when test='$table-id = $highlight-table'>black</xsl:when>
				<xsl:otherwise><xsl:value-of select='$focus-color'/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<dotml:record fillcolor='{$focus-bgcolor}' color="{$color}" 
					fontname="{$fontname}" fontsize="{$font-size-h2}" fontcolor="{$color}">
			<dotml:node id='t{$table-id}'  label='Table: {@name}' />
			<xsl:for-each select='Column'>
				<xsl:choose>
					<xsl:when test='Key'>
						<dotml:node id='c{$table-id}_{@columnId}' label='{@name} +' />
					</xsl:when>
					<xsl:when test='Reference'>
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

	<xsl:template match='Table' mode='link'>
		<xsl:apply-templates select='Column/*' mode='key-reference'/>
	</xsl:template>
	
	<xsl:template match='Table/Column/Key' mode='key-reference'>
		<xsl:variable name='key-id' select='concat("c", ../../@tableId, "_", ../@columnId)'/>
		<xsl:variable name='ref-column' select='key("columns-by-table-column-names", concat(@table, "_", @column))' />
		<xsl:variable name='ref-id' select='concat("c", $ref-column/../@tableId, "_", $ref-column/@columnId)'/>
		<dotml:edge from="{$key-id}" to="{$ref-id}" color='black' />
 	</xsl:template>

	<xsl:template match='Table/Column/Reference' mode='key-reference'>
		<xsl:variable name='ref-id' select='concat("c", ../../@tableId, "_", ../@columnId)'/>
		<xsl:variable name='key-column' select='key("columns-by-table-column-names", concat(@table, "_", @column))' />
		<xsl:variable name='key-id' select='concat("c", $key-column/../@tableId, "_", $key-column/@columnId)'/>
		<dotml:edge from="{$key-id}" to="{$ref-id}" color='{$focus-color}' />
 	</xsl:template>

	
	<xsl:template name='render-service'>
		<xsl:variable name='service' select='.'/>
		<dotml:node id='{@id}' style="solid" shape="box" label='{@name}' fillcolor='{$focus-bgcolor}' color="{$focus-color}" 
		fontname="{$fontname}" fontsize="{$font-size-h2}" fontcolor="{$focus-color}" />
		
		<!-- show the messages as nodes? -->
		<xsl:choose>
			<xsl:when test="$message-format = 'node'">
				<xsl:for-each select='Publish/Message'>
					<xsl:variable name='message-id' select="concat($service/@id, '_', @id-ref)"/>
					<dotml:node id="{$message-id}" style="solid" shape="ellipse" label='{@name}' 
					  fillcolor='{$focus-bgcolor}' color="{$message-color}" 
					  fontname="{$fontname}" fontsize="{$font-size-h3}" fontcolor="{$message-color}"/>
					<dotml:edge from="{$service/@id}" to="{$message-id}" color='{$message-color}'  />
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<!-- Render the links from published messages to services -->
	<xsl:template match='Service' mode='link'>
		<xsl:comment> Links for <xsl:value-of select='@name'/>  </xsl:comment>
		<xsl:variable name="service" select='.'/>
		
		<xsl:choose>
			<xsl:when test="$message-format = 'node'">
				<xsl:for-each select="ServiceConnections/ServiceConnection[@type='publish']/Message">
					<xsl:variable name='message-id' select="concat($service/@id, '_', @id-ref)"/>
					<xsl:variable name='to' select='../@id-ref'/>
					<dotml:edge from="{$message-id}" to="{$to}" color='{$message-color}' />
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="ServiceConnections/ServiceConnection[@type='publish']">
					<xsl:variable name='label'>
						<xsl:if test="$message-format = 'label'">
							<xsl:call-template name='concat-names'>
								<xsl:with-param name='nodes' select='Message'/>
							</xsl:call-template>
						</xsl:if>
					</xsl:variable>
					<dotml:edge from="{$service/@id}" to="{@id-ref}" label='{$label}' 
					  color="{$message-color}" fontname="{$fontname}" fontcolor="{$message-color}" fontsize="{$font-size-h2}" />
				</xsl:for-each>				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="concat-names">
		<xsl:param name="nodes" select='*'/>
		<xsl:for-each select='$nodes[@name]'>
			<xsl:if test='position() > 1'>\n</xsl:if>
			<xsl:value-of select='@name'/>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
