<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" >
<!-- 
  
  This XSL transforms schema data into an Office XML 2003 file.
     
-->
  <xsl:output method="xml" encoding="utf-8" indent="yes" />
  <xsl:param name="lang">en</xsl:param>

  <xsl:include href='excel-common.xslt' />

  <xsl:variable name='quote'>'</xsl:variable>

  <xsl:template match="/Database">
    <xsl:call-template name='excel-header-1'/>
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:html="http://www.w3.org/TR/REC-html40">

      <xsl:call-template name='workbook-styles' />

      <Worksheet ss:Name="Tables">
        <Table>
		
          <xsl:call-template name='header-row-5-columns'>
            <xsl:with-param name='column-1'>Name</xsl:with-param>
            <xsl:with-param name='column-2'>Schema</xsl:with-param>
            <xsl:with-param name='column-3'>Table</xsl:with-param>
            <xsl:with-param name='column-4'>Columns</xsl:with-param>
            <xsl:with-param name='column-5'>Rows</xsl:with-param>
          </xsl:call-template>

          <xsl:for-each select="Tables/Table">
            <xsl:sort select="@schema"/>
            <xsl:sort select="@name"/>
			
			<xsl:variable name='name' select='concat(@schema, ".", @name)'/>
			<xsl:variable name='schema' select='@schema'/>
			<xsl:variable name='table' select='@name'/>
			<xsl:variable name='columns' select='count(Column)'/>
			<xsl:variable name='rows' select='Rows/@count'/>
			
			<Row>
				<xsl:call-template name="text-cell">
					<xsl:with-param name="text" select="$name" ></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="text-cell">
					<xsl:with-param name="text" select="$schema" ></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="text-cell">
					<xsl:with-param name="text" select="$table" ></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="number-cell">
					<xsl:with-param name="value" select="$columns" ></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="number-cell">
					<xsl:with-param name="value" select="$rows" ></xsl:with-param>
				</xsl:call-template>
			</Row>
		  </xsl:for-each>
        </Table>
		
      </Worksheet>
	  
	  <Worksheet ss:Name="Columns">
        <Table>
			<xsl:call-template name='header-row-3-columns'>
				<xsl:with-param name='column-1'>Table</xsl:with-param>
				<xsl:with-param name='column-2'>Column</xsl:with-param>
				<xsl:with-param name='column-3'>DataType</xsl:with-param>
			</xsl:call-template>
			
			<xsl:for-each select="Tables/Table">
				<xsl:sort select="@schema"/>
				<xsl:sort select="@name"/>
				
				<xsl:variable name='name' select='concat(@schema, ".", @name)'/>
				<xsl:variable name='schema' select='@schema'/>
				<xsl:variable name='table' select='@name'/>			
			
				<xsl:for-each select='Column'>
					<xsl:variable name='column' select='@name'/>
					<xsl:variable name='datatype'>
						<xsl:apply-templates select="." mode='data-type'/>
					</xsl:variable>
					
					<Row>
						<xsl:call-template name="text-cell">
							<xsl:with-param name="text" select="$name" ></xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="text-cell">
							<xsl:with-param name="text" select="$column" ></xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="text-cell">
							<xsl:with-param name="text" select="$datatype" ></xsl:with-param>
						</xsl:call-template>
					</Row>
				</xsl:for-each>
			</xsl:for-each>
        </Table>
		
      </Worksheet>
	
    </Workbook>
  </xsl:template>
  
  	<xsl:template match='Column[not(@type)]' mode='data-type'>na</xsl:template>
	<xsl:template match='Column[@type]' mode='data-type'>
		<xsl:value-of select='@type'/>
		<xsl:choose>
			<xsl:when test='(@type="varchar") or (@type="nvarchar")'>
				<xsl:value-of select='concat("(", @maxLength, ")")'/>
			</xsl:when>
			<xsl:when test='(@type="char") or (@type="nchar")'>
				<xsl:value-of select='concat("(", @maxLength, ")")'/>
			</xsl:when>
			<xsl:when test='(@type="numeric") or (@type="decimal")'>
				<xsl:value-of select='concat("(", @precision, ",", @scale, ")")'/>
			</xsl:when>
			<xsl:when test='(@type="float") or (@type="decimal")'>
				<xsl:value-of select='concat("(", @precision, ")")'/>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
