<xsl:stylesheet 
    xmlns:sr="http://www.w3.org/2005/sparql-results#"
    xmlns:xsl  ="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:rdf  ="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/rsp/photos">
  <sr:sparql>
    <sr:head>
      <xsl:for-each select="photo[1]/@*">
	<sr:variable>
	  <xsl:attribute name="name"><xsl:value-of select="name()" /></xsl:attribute>
	</sr:variable>
      </xsl:for-each>
    </sr:head>

    <sr:results ordered="true" distinct="true">
      <xsl:apply-templates />
    </sr:results>
  </sr:sparql>
</xsl:template>

<xsl:template match="photo">
  <sr:result>
    <xsl:for-each select="@*">
      <sr:binding>
	<xsl:attribute name="name"><xsl:value-of select="name()" /></xsl:attribute>
	<sr:literal><xsl:value-of select="." /></sr:literal>
      </sr:binding>
    </xsl:for-each>
  </sr:result>
</xsl:template>

</xsl:stylesheet>