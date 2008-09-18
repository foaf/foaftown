<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
 <!ENTITY nsxml  'http://www.w3.org/XML/1998/namespace'>
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:skos="http://www.w3.org/2008/05/skos#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns="http://www.w3.org/2005/Atom" >


 <xsl:output indent="yes" method="xml"/>
 <xsl:template match="/">
  <rdf:RDF>
   <xsl:apply-templates select="*/entry"/>
  </rdf:RDF>
 </xsl:template>

 <xsl:template match="entry">
   <skos:Concept>
     <xsl:apply-templates select="*"/>
   </skos:Concept>
 </xsl:template>

 <xsl:template match="*">
  <xsl:variable name="ns" select="namespace-uri()"/>
  <xsl:element name="{name()}" namespace="{$ns}">
   <xsl:apply-templates select="@*"/>
   <xsl:choose>
    <xsl:when test="*"><xsl:apply-templates select="*"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
   </xsl:choose>
  </xsl:element>
 </xsl:template>

 <xsl:template match="title">
    <skos:foo>
    <xsl:apply-templates select="*"/><!-- something w descendents -->
    </skos:foo>
 </xsl:template>


</xsl:stylesheet>
