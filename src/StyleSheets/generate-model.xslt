<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

	<xsl:output method="xml" indent="yes" />
	
	<xsl:key name='column-by-table-columnId' match='Table/Column' use="concat(../@tableId, '-', @columnId)"/>
	<xsl:key name='foreign-keys-by-table-columnId' match='Table/ForeignKey' use="concat(../@tableId, '-', @columnId)"/>
	<xsl:key name='keys-by-ref-table-columnId' match='Table/ForeignKey' use="concat(@refTableId, '-', @refColumnId)"/>
	
	<xsl:key name='references-by-object-id' match='*[Reference]' use='Reference/@refObjectId'/>

	<xsl:key name='tables-by-id' match='Table' use='@tableId'/>
	<xsl:key name='views-by-id' match='View' use='@viewId'/>
	<xsl:key name='procedures-by-id' match='Procedure' use='@procedureId'/>
	<xsl:key name='functions-by-id' match='Function' use='@functionId'/>
		
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
				<xsl:apply-templates select='/Database/Objects/Table'>	
					<xsl:sort select='@name'/>
				</xsl:apply-templates>
			</Tables>
			<Views>
				<xsl:apply-templates select='/Database/Objects/View'>	
					<xsl:sort select='@name'/>
				</xsl:apply-templates>
			</Views>	
			<Procedures>
				<xsl:apply-templates select='/Database/Objects/Procedure'>	
					<xsl:sort select='@name'/>
				</xsl:apply-templates>
			</Procedures>	
			<Functions>
				<xsl:apply-templates select='/Database/Objects/Function'>	
					<xsl:sort select='@name'/>
				</xsl:apply-templates>
			</Functions>	
		</Database>
	</xsl:template>
	
	<xsl:template match='Table'>
		<xsl:variable name='tableId' select='@tableId'/>
		<xsl:copy>
			<xsl:apply-templates select='@*'/>
			<xsl:apply-templates select='Rows'/>
			<xsl:apply-templates select='Reference'/>
			<xsl:apply-templates select='Column'>
				<xsl:sort select='@columnId' data-type='number' />
			</xsl:apply-templates>
			<xsl:call-template name='used-by'>
				<xsl:with-param name='references' select='//Reference[@refObjectId=$tableId]'/>
			</xsl:call-template>
			<xsl:call-template name='uses'>
				<xsl:with-param name='references' select='Reference[@refObjectId]'/>
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>

	<xsl:template match='View'>
		<xsl:variable name='viewId' select='@viewId'/>
		<xsl:copy>
			<xsl:apply-templates select='@*'/>
			<xsl:apply-templates select='Reference'/>
			<xsl:apply-templates select='Column'>
				<xsl:sort select='@columnId' data-type='number' />
			</xsl:apply-templates>
			<xsl:call-template name='used-by'>
				<xsl:with-param name='references' select='//Reference[@refObjectId=$viewId]'/>
			</xsl:call-template>
			<xsl:call-template name='uses'>
				<xsl:with-param name='references' select='Reference[@refObjectId]'/>
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>

	<xsl:template match='Procedure'>
		<xsl:variable name='procedureId' select='@procedureId'/>
		<xsl:copy>
			<xsl:apply-templates select='@*'/>
			<xsl:apply-templates select='Reference'/>
			<xsl:call-template name='used-by'>
				<xsl:with-param name='references' select='//Reference[@refObjectId=$procedureId]'/>
			</xsl:call-template>
			<xsl:call-template name='uses'>
				<xsl:with-param name='references' select='Reference[@refObjectId]'/>
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>

	<xsl:template match='Function'>
		<xsl:variable name='functionId' select='@functionId'/>
		<xsl:copy>
			<xsl:apply-templates select='@*'/>
			<xsl:apply-templates select='Reference'/>
			<xsl:call-template name='used-by'>
				<xsl:with-param name='references' select='//Reference[@refObjectId=$functionId]'/>
			</xsl:call-template>
			<xsl:call-template name='uses'>
				<xsl:with-param name='references' select='Reference[@refObjectId]'/>
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>

	<xsl:template match='Column'>
		<xsl:variable name='column-key' select="concat(../@tableId, '-', @columnId)"/>
		<xsl:variable name='key-columns' select="key('keys-by-ref-table-columnId', $column-key)"/>
		<xsl:variable name='foreignkey-columns' select="key('foreign-keys-by-table-columnId', $column-key)"/>
		<xsl:copy>
			<xsl:apply-templates select='@*'/>
			<xsl:for-each select='$key-columns'>
				<xsl:variable name='table' select="key('tables-by-id', ../@tableId)" />
				<xsl:variable name='column' select="key('column-by-table-columnId', concat(../@tableId, '-', @columnId))" />
				<Key name='{@name}' tableId="{$table/@tableId}" table="{$table/@name}" column='{$column/@name}'/>
			</xsl:for-each>
			<xsl:for-each select='$foreignkey-columns'>
				<xsl:variable name='table' select="key('tables-by-id', @refTableId)" />
				<xsl:variable name='column' select="key('column-by-table-columnId', concat(@refTableId, '-', @refColumnId))" />
				<ForeignKey name='{@name}' tableId="{$table/@tableId}" table="{$table/@name}" column='{$column/@name}'/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template name='used-by'>
		<xsl:param name='references' select='//Reference[@invalid]'></xsl:param>
		<xsl:choose>
			<xsl:when test='count($references) > 0'>
				<xsl:element name='UsedBy'>
					<xsl:for-each select='$references/..'>
						<xsl:copy>
							<xsl:apply-templates select="@*"/>
						</xsl:copy>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>Used-By: No references</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name='uses'>
		<xsl:param name='references' select='//Reference[@invalid]'></xsl:param>
		<xsl:choose>
			<xsl:when test='count($references) > 0'>
				<xsl:variable name='tables' select="key('tables-by-id', $references/@refObjectId)"/>
				<xsl:variable name='views' select="key('views-by-id', $references/@refObjectId)"/>
				<xsl:variable name='procedures' select="key('procedures-by-id', $references/@refObjectId)"/>
				<xsl:variable name='functions' select="key('functions-by-id', $references/@refObjectId)"/>
				<xsl:element name='Uses'>
					<xsl:for-each select='$tables | $views | $procedures | $ functions'>
						<xsl:copy>
							<xsl:apply-templates select="@*"/>
						</xsl:copy>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>Uses: No references</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
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

