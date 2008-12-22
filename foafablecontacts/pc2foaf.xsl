<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
 <!ENTITY nsxml  'http://www.w3.org/XML/1998/namespace'>
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:foaf="http://xmlns.com/foaf/0.1/" 
  xmlns:pc="http://portablecontacts.net/spec/1.0#"
  xmlns="http://portablecontacts.net/spec/1.0#" >


<!-- credits: kanzaki, alberto -->

 <xsl:output indent="yes" method="xml"/>
 <xsl:template match="/">
  <rdf:RDF>
   <xsl:apply-templates select="*/pc:contact"/>
  </rdf:RDF>
 </xsl:template>

 <xsl:template match="pc:contact">
   <foaf:Agent>
   <!-- get we get pc:displayName here ? -->
  <!--   <xsl:value-of select="pc:displayName"/>-->

     <xsl:apply-templates select="*"/>
   </foaf:Agent>
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

 <xsl:template match="pc:name">
  <foaf:complex_name rdf:parseType="Resource">
    <xsl:apply-templates select="*"/><!-- something w descendents -->
  </foaf:complex_name>
 </xsl:template>

 <xsl:template match="pc:phoneNumbers">
  <foaf:tel rdf:parseType="Resource"> <!-- could make a tel: URI here, optionally -->
	<!-- are phones an online account? -->
    <xsl:apply-templates select="*"/><!-- something w descendents -->
  </foaf:tel>
 </xsl:template>


</xsl:stylesheet>
