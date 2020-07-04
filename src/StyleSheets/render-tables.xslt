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
				
				<tr>
					<th colspan='2' class='info'>Statistics</th>
				</tr>
				<tr>
					<th>Total number of Tables</th>
					<td><xsl:value-of select='count(//Tables/Table)'/></td>
				</tr>
				<tr>
					<th>Total number of Empty Tables</th>
					<td><xsl:value-of select='count(//Tables/Table/Rows[@count=0])'/></td>
				</tr>
				<tr>
					<th>Total number of Rows</th>
					<td><xsl:value-of select='sum(//Tables/Table/Rows/@count)'/></td>
				</tr>										
				<tr>
					<th>Total number of Columns</th>
					<td><xsl:value-of select='count(//Tables/Table/Column)'/></td>
				</tr>
				<tr>
					<th>Total number of Foreign Keys</th>
					<td><xsl:value-of select='count(//Tables/Table/Column/Key)'/></td>
				</tr>										
				<tr>
					<th>Total number of Views</th>
					<td><xsl:value-of select='count(//Views/View)'/></td>
				</tr>
				<tr>
					<th>Total number of Stored Procedures</th>
					<td><xsl:value-of select='count(//Procedures/Procedure)'/></td>
				</tr>
				<tr>
					<th>Total number of Functions</th>
					<td><xsl:value-of select='count(//Functions/Function)'/></td>
				</tr>
			</table>

		</div>

	</xsl:template>
	
	<xsl:template match='/Database/Tables' mode='summary'>
		<div class='panel panel-info'>
			<div class='panel-heading'>Database: <strong><xsl:value-of select='../@name'/> </strong></div>
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
							<xsl:value-of select='count(Column/Key | Column/ForeignKey)'/>
						</td>
						<td><xsl:apply-templates select='Rows' mode='badge'/></td>
					</tr>
				</xsl:for-each>
				<tr>
					<th colspan='5'><a id='relationships' name='relationships'/>Database Relationships</th>
				</tr>
				<tr>
					<td colspan='5'>
						<img src="Graphs/db_Relationships.svg" class='img-responsive'/>
						<div class='text-right'><a href="Graphs/db_Relationships.png">Source</a></div>
					</td>
				</tr>
			</table>
		</div>
	</xsl:template>

	<!-- Tables -->	
 	<xsl:template match='/Database/Tables/Table' mode='table'>
		<xsl:variable name='has-keys' select='count(Column/*) &gt; 0'/>
		<a id='{@tableId}' name='{@tableId}'/>
		<div class='panel panel-primary'>
			<div class='panel-heading'>Table: <strong><xsl:value-of select='@name'/> </strong>
				<xsl:apply-templates select='Rows' mode='badge'/>
			</div>
			<div class='panel-body'>
				<table class='table table-hover table-border'>
					<tr>
						<th>#</th>
						<th>Column</th>
						<th>DataType</th>
						<th/>
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
								<xsl:if test='count(Key | ForeignKey) > 0'>
									<div class="btn-group-vertical" role="group" >							
										<xsl:apply-templates select='Key' mode='list-group-link'/>
										<xsl:apply-templates select='ForeignKey' mode='list-group-link'/>
									</div>
								</xsl:if>
							</td>
						</tr>
					</xsl:for-each>
					<tr>
						<th colspan='4'>Relationships</th>
					</tr>
					<xsl:if test='Uses'>
						<tr>
							<td colspan='4'>
								<div class="btn-group-vertical" role="group" >							
									<xsl:apply-templates select='Uses/*' mode='list-group-link'/>
								</div>
							</td>
						</tr>
					</xsl:if>
					<tr>
						<td colspan='4'>
							<img src="Graphs/tbl_{@name}.svg" class='img-responsive'/>
							<div class='text-right'><a href="Graphs/tbl_{@name}.png">Source</a></div>
						</td>					
					</tr>
				</table>
			</div>
		</div>
	</xsl:template>
	
	<!-- Views -->

 	<xsl:template match='/Database/Views/View' mode='table'>
		<xsl:variable name='has-keys' select='count(Column/*) &gt; 0'/>
		<a id='{@tableId}' name='{@tableId}'/>
		<div class='panel panel-primary'>
			<div class='panel-heading'>View: <strong><xsl:value-of select='@name'/> </strong>
			</div>
			<div class='panel-body'>
				<table class='table table-hover table-border'>
					<tr>
						<th>#</th>
						<th>Column</th>
						<th>DataType</th>
						<th></th>
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
								<xsl:if test='count(Key | ForeignKey) > 0'>
									<div class="btn-group-vertical" role="group" >							
										<xsl:apply-templates select='Key' mode='list-group-link'/>
										<xsl:apply-templates select='ForeignKey' mode='list-group-link'/>
									</div>
								</xsl:if>
							</td>
						</tr>
					</xsl:for-each>
					<tr>
						<th colspan='4'>Relationships</th>
					</tr>
					<xsl:if test='Uses'>
						<tr>
							<td colspan='4'>
								<div class="btn-group-vertical" role="group" >							
									<xsl:apply-templates select='Uses/*' mode='list-group-link'/>
								</div>
							</td>
						</tr>
					</xsl:if>
					<tr>
						<td colspan='4'>
							<img src="Graphs/vw_{@name}.svg" class='img-responsive'/>
							<div class='text-right'><a href="Graphs/vw_{@name}.png">Source</a></div>
						</td>					
					</tr>
				</table>
			</div>
		</div>
	</xsl:template>

	<xsl:template match='/Database/Views' mode='summary'>
		<div class='panel panel-info'>
			<div class='panel-heading'>Database: <strong><xsl:value-of select='../@name'/> </strong></div>
				<table class='table table-hover table-border'>
				<tr>
					<th>#</th>
					<th>View</th>
					<th>Columns</th>
					<th>References</th>
				</tr>
				<xsl:for-each select='Table'>
					<xsl:sort select='@schema'/>
					<xsl:sort select='@name'/>
					<tr>
						<td><xsl:value-of select='position()'/></td>
						<td>
							<a href='#{@viewId}' title='{@name}'>
								<xsl:value-of select='@schema'/>
								<xsl:text>.</xsl:text>
								<xsl:value-of select='@name'/>
							</a>
						</td>
						<td>
							<xsl:value-of select='count(Column)'/>
						</td>
						<td>
							<xsl:value-of select='count(UsedBy/* | Uses/*)'/>
						</td>
					</tr>
				</xsl:for-each>
				<tr>
					<th colspan='4'><a id='view-relationships' name='relationships'/>View Relationships</th>
				</tr>
				<tr>
					<td colspan='4'>
						<img src="Graphs/db_views.svg" class='img-responsive'/>
						<div class='text-right'><a href="Graphs/db_views.png">Source</a></div>
					</td>
				</tr>
			</table>
		</div>
	</xsl:template>

	<xsl:template name='generate-column-table'>
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

	
	<xsl:template match='ForeignKey' mode='list-group-link'>	
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

	<xsl:template match='Uses/Table' mode='list-group-link'>	
		<a href='#{@tableId}' title='Table: {@name}' class='btn btn-primary btn-sm'>
			<span class="glyphicon glyphicon-arrow-right" aria-hidden="true"/> 
			<xsl:text> </xsl:text>
			<xsl:value-of select='@name'/>
		</a>
	</xsl:template>

	<xsl:template match='Uses/View' mode='list-group-link'>	
		<a href='#{@viewId}' title='View: {@name}' class='btn btn-primary btn-sm'>
			<span class="glyphicon glyphicon-arrow-right" aria-hidden="true"/> 
			<xsl:text> </xsl:text>
			<xsl:value-of select='@name'/>
		</a>
	</xsl:template>

	<xsl:template match='Uses/Procedure' mode='list-group-link'>	
		<a href='#{@procedureId}' title='Procedure: {@name}' class='btn btn-primary btn-sm'>
			<span class="glyphicon glyphicon-arrow-right" aria-hidden="true"/> 
			<xsl:text> </xsl:text>
			<xsl:value-of select='@name'/>
		</a>
	</xsl:template>

	<xsl:template match='Uses/Function' mode='list-group-link'>	
		<a href='#{@procedureId}' title='Function: {@name}' class='btn btn-primary btn-sm'>
			<span class="glyphicon glyphicon-arrow-right" aria-hidden="true"/> 
			<xsl:text> </xsl:text>
			<xsl:value-of select='@name'/>
		</a>
	</xsl:template>


</xsl:stylesheet>
