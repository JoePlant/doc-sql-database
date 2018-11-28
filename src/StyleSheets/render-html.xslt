<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
 <xsl:output
     method="html"
     doctype-system="about:legacy-compat"
     encoding="UTF-8"
     indent="yes" />

	<xsl:include href='render-tables.xslt' />
<!--	<xsl:include href='render-tables.xslt'/>
	<xsl:include href='render-columns.xslt'/>
-->	
	<xsl:variable name='crlf'>
</xsl:variable>

	<xsl:variable name='db-name' select='/Database/@name' />

	<xsl:template match="/">
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title><xsl:value-of select='$db-name'/></title>

    <!-- Bootstrap -->
    <link href="lib/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="css/database.css" rel="stylesheet"/>

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
    <a id='top' name='top'/>

    <nav class="navbar navbar-inverse navbar-static-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#"><xsl:value-of select='$db-name'/></a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#">Home</a></li>
            <li>
				<a href="#tables"><xsl:text>Tables </xsl:text><xsl:apply-templates select='/Database/Tables' mode='count-badge'/></a>
			</li>
            <li><a href="#relationships"><xsl:text>Relationships </xsl:text>
				<xsl:call-template name='count-badge'>
					<xsl:with-param name='items' select='//Table/Column/Key'/>
				</xsl:call-template>
			</a></li>
			<p class="navbar-text navbar-right text-right">Built using <a href="https://joeplant.github.io/doc-sql-database" class="navbar-link">doc-sql-database</a></p>

          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </nav>
 
  
  <div class="container">
  	<div class='col-md-2' role='complimentary' >
		<ul class="nav hidden-print hidden-xs hidden-sm" data-spy='affix'>
			<li>
				<a href="#">Summary</a>
			</li>
			<li>
				<a href="#relationships">Relationships</a>
			</li>
			<li>
				<a href='#tables'>Tables</a>
			</li>
		</ul>
	</div>
	<div class='col-md-10' role='main' >
		<a name='summary'/>
		<xsl:apply-templates select='/Database' mode='summary'/>
		
		<h3>Summary</h3>
			<xsl:apply-templates select='/Database/Tables' mode='summary'/>
		<a name='tables'/>
		<h3>Tables</h3>
		<xsl:apply-templates select='/Database/Tables/Table' mode='table'/>
	</div>

	<hr/>
	</div>
	<nav class="navbar navbar-default navbar-fixed-bottom">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="#"><xsl:value-of select='$db-name'/></a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li>
				<a href="#tables"><xsl:text>Tables </xsl:text><xsl:apply-templates select='/Database/Tables' mode='count-badge'/></a>
			</li> 
            <li><a href="#relationships"><xsl:text>Relationships </xsl:text>
				<xsl:call-template name='count-badge'>
					<xsl:with-param name='items' select='//Table/Column/Key'/>
				</xsl:call-template>
			</a></li>
			<p class="navbar-text navbar-right">Built using <a href="https://joeplant.github.io/doc-sql-database" class="navbar-link">doc-sql-database</a></p>
          </ul>
        </div>
      </div>
	</nav>
	
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="lib/jquery/jquery.min.js"/>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="lib/bootstrap/js/bootstrap.min.js"/>
  </body>
</html>
  </xsl:template> 
  
  <xsl:template match='*' mode='count-badge'>
	<xsl:call-template name='count-badge'>
		<xsl:with-param name='items' select='*'/>
	</xsl:call-template>
  </xsl:template>
  
  <xsl:template name='count-badge'>
	<xsl:param name='items' select='*'/>
	<xsl:choose>
		<xsl:when test='count($items) = 0'/>
		<xsl:otherwise>
			<xsl:text> </xsl:text>
			<span class='badge'><xsl:value-of select='count($items)'/></span>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  

</xsl:stylesheet>
