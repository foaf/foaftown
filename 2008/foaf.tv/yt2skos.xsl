<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:skos="http://www.w3.org/2008/05/skos#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/">

<!-- 

	YouTube to SKOS/FOAF Extractor
	Takes as input an Atom feed from a YouTube favourites lookup
	(note that favourites are spread across possibly many such docs).
	
	When we find category information attached to a video, either tags
	in keywords.cat (most likely supplied by the poster of the video), or 
	youtube's own categories (categories.cat) we emit these as SKOS on the 
	dc:subject of the video.

	Todo: relate the User/person/account to the videos and category.

-->

<xsl:output method="xml" indent="yes"/>
<xsl:template match="/">
<rdf:RDF>
  <foaf:Person rdf:about="#who">
    <foaf:holdsAccount rdf:resource="http://example.com/"/>
  </foaf:Person>
    <xsl:apply-templates select="/atom:feed/atom:head"/>
      <xsl:apply-templates select="/atom:feed"/>

</rdf:RDF>
</xsl:template>

<xsl:template match="atom:feed/atom:head">
  <foaf:Document rdf:about="">
    <dc:title><xsl:value-of select="atom:title"/></dc:title>
  </foaf:Document>
<!--
  <xsl:if test="atom:tagline"><xsl:value-of select="atom:tagline"/></xsl:if>
  <xsl:if test="atom:subtitle"><xsl:value-of select="atom:subtitle"/></xsl:if>
-->
</xsl:template>

<xsl:template match="/atom:feed">
  <!-- 
    <xsl:value-of select="atom:title"/> 
    <xsl:if test="atom:tagline"><xsl:value-of select="atom:tagline"/></xsl:if>
    <xsl:if test="atom:subtitle"><xsl:value-of select="atom:subtitle"/></xsl:if>
    -->
  <xsl:apply-templates select="atom:entry"/>
</xsl:template>
        
<xsl:template match="atom:entry">

  <foaf:Document rdf:about="{atom:link[@rel='alternate']/@href}"> 

<dc:title>    <xsl:if test="atom:title"><xsl:value-of select="atom:title"/></xsl:if></dc:title>
  <xsl:if test="atom:category">

      <dc:subject>
      <!-- -->
        <skos:Concept rdf:about="{concat(atom:category/@scheme, '#', atom:category/@term)}">       
	  <!-- assign genids? youtube URIs? -->

          <!-- see if this is free tags 
          <xsl:if 
            test="equal(atom:category/@scheme,'http://gdata.youtube.com/schemas/2007/keywords.cat')"
            ><rdf:type rdf:resource="http://xmlns.com/foaf/0.1/FreeTag"/></xsl:if>
                    -->
          <skos:inScheme rdf:resource="{atom:category/@scheme}"/>
          <skos:label><xsl:value-of select="atom:category/@term"/></skos:label>
        </skos:Concept>
      </dc:subject>

  </xsl:if>
  </foaf:Document>

  <foaf:Person rdf:about="#who">
    <foaf:interest_topic rdf:resource="{concat(atom:category/@scheme, '#', atom:category/@term)}"/> 
  </foaf:Person>

</xsl:template>
    
</xsl:stylesheet>


