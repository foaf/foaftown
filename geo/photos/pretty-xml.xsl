<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:res="http://www.w3.org/2005/sparql-results#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:xhtml="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="res xsl rdf xhtml">
  
   <xsl:output method="xml"/>
   <xsl:param name="indent-increment" select="'   '" />

   <xsl:template match="*">
      <xsl:param name="indent" select="'&#xA;'"/>

      <xsl:value-of select="$indent"/>
      <xsl:copy>
        <xsl:copy-of select="@*" />
        <xsl:apply-templates>
          <xsl:with-param name="indent"
               select="concat($indent, $indent-increment)"/>
        </xsl:apply-templates>
        <xsl:if test="*">
          <xsl:value-of select="$indent"/>
        </xsl:if>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="comment()|processing-instruction()">
      <xsl:copy />
   </xsl:template>

   <!-- WARNING: this is dangerous. Handle with care -->
   <xsl:template match="text()[normalize-space(.)='']"/>

</xsl:stylesheet>