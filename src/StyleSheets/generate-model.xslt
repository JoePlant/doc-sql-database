<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

	<xsl:output method="xml" indent="yes" />
	
	<xsl:key name='column-by-table-columnId' match='Table/Column' use="concat(../@tableId, '-', @columnId)"/>
	<xsl:key name='foreign-keys-by-table-columnId' match='Table/ForeignKey' use="concat(../@tableId, '-', @columnId)"/>
	<xsl:key name='keys-by-ref-table-columnId' match='Table/ForeignKey' use="concat(@refTableId, '-', @refColumnId)"/>
	
	<xsl:key name='table-by-id' match='Table' use='@tableId'/>
		
	<xsl:template match='/'>
		<xsl:variable name='db-name'>
			<xsl:choose>
				<xsl:when test='/Database/@name'><xsl:value-of select='/Database/@name'/></xsl:when>
				<xsl:otherwise>{database}</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<Database name='{$db-name}'>
			<xsl:apply-templates select='/Database/@*'/>
			<!-- insert the name attribute is not available -->
			<xsl:if test='not(/Database/@name)'>
				<xsl:attribute name='name'>{database}</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select='/Database/File'/>
			<Tables>
				<xsl:apply-templates select='/Database/Tables/Table'>	
					<xsl:sort select='@name'/>
				</xsl:apply-templates>
			</Tables>
		</Database>
	</xsl:template>
	
	<xsl:template match='Table'>
		<xsl:copy>
			<xsl:apply-templates select='@*'/>
			<xsl:apply-templates select='Rows'/>
			<xsl:apply-templates select='Column'>
				<xsl:sort select='@columnId' data-type='number' />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match='Column'>
		<xsl:variable name='column-key' select="concat(../@tableId, '-', @columnId)"/>
		<xsl:variable name='key-columns' select="key('keys-by-ref-table-columnId', $column-key)"/>
		<xsl:variable name='foreignkey-columns' select="key('foreign-keys-by-table-columnId', $column-key)"/>
		<xsl:copy>
			<xsl:apply-templates select='@*'/>
			<xsl:for-each select='$key-columns'>
				<xsl:variable name='table' select="key('table-by-id', ../@tableId)" />
				<xsl:variable name='column' select="key('column-by-table-columnId', concat(../@tableId, '-', @columnId))" />
				<Key name='{@name}' tableId="{$table/@tableId}" table="{$table/@name}" column='{$column/@name}'/>
			</xsl:for-each>
			<xsl:for-each select='$foreignkey-columns'>
				<xsl:variable name='table' select="key('table-by-id', @refTableId)" />
				<xsl:variable name='column' select="key('column-by-table-columnId', concat(@refTableId, '-', @refColumnId))" />
				<Reference name='{@name}' tableId="{$table/@tableId}" table="{$table/@name}" column='{$column/@name}'/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*">
		<xsl:copy/>
	</xsl:template>

</xsl:stylesheet>

