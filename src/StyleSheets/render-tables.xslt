<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
	<xsl:template match='Database' mode='summary'>
		<div class='panel panel-info'>
			<div class='panel-heading'>Database: <strong><xsl:value-of select='@name'/> </strong></div>
			<table class='table table-hover'>
				<xsl:for-each select='@*'>
					<tr>
						<th>
							<xsl:value-of select='name()'/>
						</th>
						<td>
							<xsl:value-of select='.'/>
						</td>
					</tr>
				</xsl:for-each>
				<xsl:for-each select='File'>
					<tr>
						<th>
							<xsl:value-of select='@name'/>
						</th>
						<td>
							<xsl:value-of select='@physical'/>
						</td>
					</tr>
				</xsl:for-each>
			</table>

		</div>

	</xsl:template>
	
	<xsl:template match='/Database/Tables' mode='summary'>
		<div class='panel panel-info'>
			<div class='panel-heading'>Database: <strong><xsl:value-of select='@name'/> </strong></div>
				<table class='table table-hover table-border'>
				<tr>
					<th>#</th>
					<th>Table</th>
					<th>Columns</th>
					<th>Relationships</th>
					<th>Rows</th>
				</tr>
				<xsl:for-each select='Table'>
					<xsl:sort select='@schema'/>
					<xsl:sort select='@name'/>
					<tr>
						<td><xsl:value-of select='position()'/></td>
						<td>
							<a href='#{@tableId}' title='{@name}'>
								<xsl:value-of select='@schema'/>
								<xsl:text>.</xsl:text>
								<xsl:value-of select='@name'/>
							</a>
						</td>
						<td>
							<xsl:value-of select='count(Column)'/>
						</td>
						<td>
							<xsl:value-of select='count(Column/Key | Column/Reference)'/>
						</td>
						<td><xsl:apply-templates select='Rows' mode='badge'/></td>
					</tr>
				</xsl:for-each>
			</table>
		</div>
	</xsl:template>
	
 	<xsl:template match='/Database/Tables/Table' mode='table'>
		<xsl:variable name='has-keys' select='count(Column/*) &gt; 0'/>
		<a id='{@tableId}' name='{@tableId}'/>
		<div class='panel panel-primary'>
			<div class='panel-heading'>Table: <strong><xsl:value-of select='@name'/> </strong>
				<xsl:apply-templates select='Rows' mode='badge'/>
			</div>
			<div class='panel-body'>
				<div class='container'>
					<div class='row'>
						<div class='col-xs-8 col-md-6'>
							<xsl:call-template name='generate-column-table'/>
							
							
						</div>
						<div class='col-xs-4 col-md-6'>
							<p>Relationships</p>
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template name='generate-column-table'>
		<table class='table table-hover table-border'>
			<tr>
				<th>#</th>
				<th>Column</th>
				<th>DataType</th>
				<th/>
				<!--
				<xsl:if test='$has-keys'>
					<th>Keys</th>
				</xsl:if>
				-->
			</tr>
			<xsl:for-each select='Column'>
				<tr>
					<td><xsl:value-of select='@columnId'/></td>
					<td>
						<xsl:value-of select='@name'/>
					</td>
					<td>
						<xsl:apply-templates select="." mode='data-type'/>
					</td>
					<td>
						<xsl:if test='count(Key | Reference) > 0'>
							<div class="btn-group-vertical" role="group" >							
								<xsl:apply-templates select='Key' mode='list-group-link'/>
								<xsl:apply-templates select='Reference' mode='list-group-link'/>
							</div>
						</xsl:if>
					</td>
				</tr>
			</xsl:for-each>
		</table>
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
	
	<xsl:template match='Rows' mode='badge'>
		<xsl:choose>
			<xsl:when test='@count = 0'/>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
				<span class='badge'><xsl:value-of select='@count'/></span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
	<xsl:template match='Reference' mode='list-group-link'>	
		<a href='#{@tableId}' title='{@name}' class='btn btn-default btn-sm'>
			<span class="glyphicon glyphicon-arrow-right" aria-hidden="true"/> 
			<xsl:text> </xsl:text>
			<xsl:value-of select='@table'/>
		</a>
	</xsl:template>
	
	<xsl:template match='Key' mode='list-group-link'>	
		<a href='#{@tableId}' title='{@name}' class='btn btn-primary btn-sm'>
			<span class="glyphicon glyphicon-arrow-right" aria-hidden="true"/> 
			<xsl:text> </xsl:text>
			<xsl:value-of select='@table'/>
		</a>
	</xsl:template>

</xsl:stylesheet>
