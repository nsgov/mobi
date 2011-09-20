<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns:pg="http://gov.ns.ca/xmlns/page"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" indent="yes" method="text" />

<xsl:template match="/pg:page">
  <xsl:apply-templates select="pg:content/pg:contentlinks/pg:link"/>
  true
</xsl:template>

<xsl:template match="pg:link">
  <xsl:variable name="dir" select="@page"/>
  <xsl:variable name="file"><xsl:value-of select="@page"/>/<xsl:value-of select="@page"/>.xml</xsl:variable>
[ ! -d "<xsl:value-of select="$dir"/>" ] &amp;&amp; mkdir "<xsl:value-of select="$dir"/>"
[ ! -f "<xsl:value-of select="$file"/>" ] &amp;&amp; sed "s~TITLE~<xsl:value-of select="$dir"/>~g" &lt; newlocation.xml &gt; "<xsl:value-of select="$file"/>"
[ ! -f "<xsl:value-of select="$dir"/>/Makefile" ] &amp;&amp; cp newlocation.mk "<xsl:value-of select="$dir"/>/Makefile"
</xsl:template>

</xsl:transform>
