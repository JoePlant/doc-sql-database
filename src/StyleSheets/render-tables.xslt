<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
 	<xsl:template match='/Database/Tables/Table' mode='table'>
		<xsl:variable name='has-keys' select='count(Column/*) &gt; 0'/>
		<a id='{@tableId}' name='{@tableId}'/>
		<div class='panel panel-primary'>
			<div class='panel-heading'>Table: <strong><xsl:value-of select='@name'/></strong></div>
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
					<td>na</td>
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
