<xsl:stylesheet 
    xmlns:sr="http://www.w3.org/2005/sparql-results#"
    xmlns:xsl  ="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:rdf  ="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

<xsl:output method="text"/>

<xsl:template match="/rsp/photos">
{ "head": { "vars": [
      <xsl:for-each select="photo[1]/@*">
	"<xsl:value-of select="name()" />"
	<xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each> ]
  } ,
"results": { "distinct": true , "ordered": true ,
   "bindings": [ <xsl:apply-templates /> ]
  }
}
</xsl:template>

<xsl:template match="photo">  {
    <xsl:for-each select="@*">
      "<xsl:value-of select="name()" />" : { "type": "literal" , "value": "<xsl:value-of select="." />" }
      	<xsl:if test="position() != last()">, </xsl:if></xsl:for-each>
  }</xsl:template>

</xsl:stylesheet>