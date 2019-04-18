<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
				xmlns="urn:schemas-microsoft-com:office:spreadsheet"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" 
                xmlns:html="http://www.w3.org/TR/REC-html40"
                xmlns:x="urn:schemas-microsoft-com:office:excel">

	<xsl:template name='excel-header-1'>
		<xsl:processing-instruction name="mso-application">
		  <xsl:text>progid="Excel.Sheet"</xsl:text>
		</xsl:processing-instruction>
	</xsl:template>
	
	<xsl:template name='workbook-styles'>
		<Styles>
			<Style ss:ID='header' ss:Name='Header'>
				<Font ss:FontName="Arial" ss:Bold="1" />
			</Style>
			<Style ss:ID='text' ss:Name='Normal'>
				<Font ss:FontName="Arial" />
			</Style>
      <Style ss:ID='value' ss:Parent='text' ss:Name='Value'>
        <Font ss:Bold="1"/>
      </Style>
      <Style ss:ID='hyperlink' ss:Parent='text' ss:Name='Hyperlink'>
        <Font ss:Underline="Single" ss:Color="#0000FF"/>
      </Style>
      <Style ss:ID='inherited-value' ss:Parent='text' ss:Name='Inherited Value'>
        <Font ss:Italic="1" />
      </Style>
      <Style ss:ID='default-value' ss:Parent='text' ss:Name='Default Value'>
        <Font ss:Italic="1" ss:Color='Silver' />
      </Style>
      <Style ss:ID='no-value' ss:Parent='text' ss:Name='No Value'>
        <Interior ss:Pattern='Solid' ss:Color='Silver'/>
      </Style>
      <Style ss:ID='merge-down' ss:Parent='text' ss:Name='Merged Down'>
        <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
      </Style>
    </Styles>
	</xsl:template>
	
	<xsl:template name='style-cell'>
		<xsl:param name='text' select='.' />
		<xsl:param name='style'>text</xsl:param>
    <xsl:param name='type'>String</xsl:param>
    <xsl:param name='cell-index'/>
    <xsl:param name='merge-down'/>
    <xsl:param name='merge-across'/>
    <xsl:param name='comment'/>
    <xsl:param name='hyperlink'/>
		<Cell>
      <xsl:if test="$merge-down">
        <xsl:if test="$merge-down > 0">
          <xsl:attribute name="ss:MergeDown">
            <xsl:value-of select="$merge-down"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$merge-across">
        <xsl:if test="$merge-across > 0">
          <xsl:attribute name="ss:MergeAcross">
            <xsl:value-of select="$merge-across"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$cell-index">
        <xsl:if test="$cell-index > 0">
          <xsl:attribute name="ss:Index">
            <xsl:value-of select="$cell-index"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$style">
        <xsl:attribute name="ss:StyleID">
          <xsl:value-of select="$style"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$hyperlink">
        <xsl:attribute name="ss:HRef">
          <xsl:value-of select="$hyperlink"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$text and string-length($text) > 0">
        <Data ss:Type="{$type}"><xsl:value-of select='$text'/></Data>
      </xsl:if>
      <xsl:if test='string-length($comment) > 0 and not($comment = $text)' xml:space='preserve'>
        <Comment><Data><html:Font html:Face="Tahoma" x:Family="Swiss" html:Size="9" html:Color="#000000"><xsl:value-of select='$comment'/></html:Font></Data></Comment>
      </xsl:if>
		</Cell>
	</xsl:template>

  <xsl:template name='merge-cell'>
    <xsl:param name='text' select='.' />
    <xsl:param name='style'>text</xsl:param>
    <xsl:param name='type'>String</xsl:param>
    <xsl:param name='cell-index'/>
    <xsl:param name='merge-down'>0</xsl:param>
    <xsl:param name='merge-across'>0</xsl:param>
    <xsl:param name='comment'/>
    <xsl:call-template name='style-cell'>
      <xsl:with-param name='text' select='$text'/>
      <xsl:with-param name='style' select='$style'/>
      <xsl:with-param name='type' select='$type'/>
      <xsl:with-param name='cell-index' select='$cell-index'/>
      <xsl:with-param name='merge-down' select='$merge-down'/>
      <xsl:with-param name='merge-across' select='$merge-across'/>
      <xsl:with-param name='comment' select='$comment'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='text-cell'>
    <xsl:param name='text' select='.'/>
    <xsl:param name='comment'/>
    <xsl:param name='cell-index'/>
    <xsl:param name='style'>text</xsl:param>
    <xsl:call-template name='style-cell'>
      <xsl:with-param name='text' select='$text'/>
      <xsl:with-param name='style' select='$style'/>
      <xsl:with-param name='cell-index' select='$cell-index'/>
      <xsl:with-param name='comment' select='$comment'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='hyperlink-cell'>
    <xsl:param name='text' select='.'/>
    <xsl:param name='sheet-ref'></xsl:param>
    <xsl:param name='cell-ref'>A1</xsl:param>
    <xsl:param name='comment'/>
    <xsl:param name='cell-index'/>
    <xsl:param name='style'>hyperlink</xsl:param>
    <xsl:call-template name='style-cell'>
      <xsl:with-param name='text' select='$text'/>
      <xsl:with-param name='style' select='$style'/>
      <xsl:with-param name='cell-index' select='$cell-index'/>
      <xsl:with-param name='comment' select='$comment'/>
      <xsl:with-param name='hyperlink'>
        <xsl:text>#</xsl:text>
        <xsl:if test='$sheet-ref'>
          <xsl:value-of select="concat($sheet-ref, '!')"/>
        </xsl:if>
        <xsl:value-of select="$cell-ref"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='number-cell'>
    <xsl:param name='value' select='.'/>
    <xsl:param name='comment'/>
    <xsl:param name='style'>text</xsl:param>
    <xsl:call-template name='style-cell'>
      <xsl:with-param name='text' select='$value'/>
      <xsl:with-param name='style' select='$style'/>
      <xsl:with-param name='type'>Number</xsl:with-param>
      <xsl:with-param name='comment' select='$comment'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="no-value">
    <xsl:param name="merge-down">0</xsl:param>
    <xsl:call-template name="style-cell">
      <xsl:with-param name="style">no-value</xsl:with-param>
      <xsl:with-param name="text"></xsl:with-param>
      <xsl:with-param name="comment"></xsl:with-param>
      <xsl:with-param name="merge-down" select="$merge-down"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='header-cell'>
    <xsl:param name='text' select='.'/>
    <xsl:param name='comment'/>
    <xsl:param name='merge-across'/>
    <xsl:call-template name='style-cell'>
      <xsl:with-param name='text' select='$text'/>
      <xsl:with-param name='style'>header</xsl:with-param>
      <xsl:with-param name='comment' select='$comment'/>
      <xsl:with-param name='merge-across' select='$merge-across'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='data-row-2-columns'>
		<xsl:param name='column-1'/>
		<xsl:param name='column-2'/>
		<xsl:call-template name='excel-row-X-columns'>
			<xsl:with-param name='columns'>2</xsl:with-param>
			<xsl:with-param name='column-1' select='$column-1'/>
			<xsl:with-param name='column-2' select='$column-2'/>
			<xsl:with-param name='style'>text</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

  <xsl:template name='data-row-3-columns'>
    <xsl:param name='column-1'/>
    <xsl:param name='column-2'/>
    <xsl:param name='column-3'/>
    <xsl:call-template name='excel-row-X-columns'>
      <xsl:with-param name='columns'>3</xsl:with-param>
      <xsl:with-param name='column-1' select='$column-1'/>
      <xsl:with-param name='column-2' select='$column-2'/>
      <xsl:with-param name='column-3' select='$column-3'/>
      <xsl:with-param name='style'>text</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='data-row-4-columns'>
    <xsl:param name='column-1'/>
    <xsl:param name='column-2'/>
    <xsl:param name='column-3'/>
    <xsl:param name='column-4'/>

    <xsl:call-template name='excel-row-X-columns'>
      <xsl:with-param name='columns'>4</xsl:with-param>
      <xsl:with-param name='column-1' select='$column-1'/>
      <xsl:with-param name='column-2' select='$column-2'/>
      <xsl:with-param name='column-3' select='$column-3'/>
      <xsl:with-param name='column-4' select='$column-4'/>
      <xsl:with-param name='style'>text</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='data-row-5-columns'>
		<xsl:param name='column-1'/>
		<xsl:param name='column-2'/>
		<xsl:param name='column-3'/>
		<xsl:param name='column-4'/>
		<xsl:param name='column-5'/>
		
		<xsl:call-template name='excel-row-X-columns'>
			<xsl:with-param name='columns'>5</xsl:with-param>
			<xsl:with-param name='column-1' select='$column-1'/>
			<xsl:with-param name='column-2' select='$column-2'/>
			<xsl:with-param name='column-3' select='$column-3'/>
			<xsl:with-param name='column-4' select='$column-4'/>
			<xsl:with-param name='column-5' select='$column-5'/>
			<xsl:with-param name='style'>text</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	

	<xsl:template name='header-row-5-columns'>
		<xsl:param name='column-1'/>
		<xsl:param name='column-2'/>
		<xsl:param name='column-3'/>
		<xsl:param name='column-4'/>
		<xsl:param name='column-5'/>
		
		<xsl:call-template name='excel-row-X-columns'>
			<xsl:with-param name='columns'>5</xsl:with-param>
			<xsl:with-param name='column-1' select='$column-1'/>
			<xsl:with-param name='column-2' select='$column-2'/>
			<xsl:with-param name='column-3' select='$column-3'/>
			<xsl:with-param name='column-4' select='$column-4'/>
			<xsl:with-param name='column-5' select='$column-5'/>
			<xsl:with-param name='style'>header</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	
	<xsl:template name='header-row-2-columns'>
		<xsl:param name='column-1'/>
		<xsl:param name='column-2'/>
		<xsl:call-template name='excel-row-X-columns'>
			<xsl:with-param name='columns'>2</xsl:with-param>
			<xsl:with-param name='column-1' select='$column-1'/>
			<xsl:with-param name='column-2' select='$column-2'/>
			<xsl:with-param name='style'>header</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

  <xsl:template name='header-row-3-columns'>
    <xsl:param name='column-1'/>
    <xsl:param name='column-2'/>
    <xsl:param name='column-3'/>

    <xsl:call-template name='excel-row-X-columns'>
      <xsl:with-param name='columns'>3</xsl:with-param>
      <xsl:with-param name='column-1' select='$column-1'/>
      <xsl:with-param name='column-2' select='$column-2'/>
      <xsl:with-param name='column-3' select='$column-3'/>
      <xsl:with-param name='style'>header</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name='header-row-4-columns'>
    <xsl:param name='column-1'/>
    <xsl:param name='column-2'/>
    <xsl:param name='column-3'/>
    <xsl:param name='column-4'/>

    <xsl:call-template name='excel-row-X-columns'>
      <xsl:with-param name='columns'>4</xsl:with-param>
      <xsl:with-param name='column-1' select='$column-1'/>
      <xsl:with-param name='column-2' select='$column-2'/>
      <xsl:with-param name='column-3' select='$column-3'/>
      <xsl:with-param name='column-4' select='$column-4'/>
      <xsl:with-param name='style'>header</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name='excel-row-X-columns'>
		<xsl:param name="columns">5</xsl:param>
		<xsl:param name='column-1'/>
		<xsl:param name='column-2'/>
		<xsl:param name='column-3'/>
		<xsl:param name='column-4'/>
		<xsl:param name='column-5'/>
		<xsl:param name='style'>text</xsl:param>
		
		<Row>
			<xsl:call-template name='style-cell'>
				<xsl:with-param name='text' select='$column-1'/>
				<xsl:with-param name='style' select='$style' />
			</xsl:call-template>
			<xsl:if test='$columns >= 2'>
				<xsl:call-template name='style-cell'>
					<xsl:with-param name='text' select='$column-2'/>
					<xsl:with-param name='style' select='$style' />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test='$columns >= 3'>
				<xsl:call-template name='style-cell'>
					<xsl:with-param name='text' select='$column-3'/>
					<xsl:with-param name='style' select='$style' />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test='$columns >= 4'>
				<xsl:call-template name='style-cell'>
					<xsl:with-param name='text' select='$column-4'/>
					<xsl:with-param name='style' select='$style' />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test='$columns >= 5'>
				<xsl:call-template name='style-cell'>
					<xsl:with-param name='text' select='$column-5'/>
					<xsl:with-param name='style' select='$style' />
				</xsl:call-template>
			</xsl:if>
		</Row>
	</xsl:template>

</xsl:stylesheet>
