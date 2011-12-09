<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pg="http://gov.ns.ca/xmlns/page"
	       xmlns:access="http://gov.ns.ca/xmlns/access-marker"
               exclude-result-prefixes="pg access">
<xsl:import href="../../xsl/mobilepage.xsl"/>

<xsl:variable name="markers" select="document('locations.xml')/markers"/>

<xsl:template match="pg:contentlinks">
  <h1 class="bucketHead"><img src="{$SITEROOT}/location/accessns/accessns-logo.png" alt="Access Nova Scotia"/></h1>
  <ul class="bucketList">
    <xsl:apply-templates/>
  </ul>
</xsl:template>

<xsl:template name="access-place"
  ><xsl:choose><xsl:when test="@place"><xsl:value-of select="@place"/></xsl:when><xsl:otherwise><xsl:value-of select="/pg:page/pg:title[@lang='en' or not(@lang)]"/></xsl:otherwise></xsl:choose></xsl:template>
<xsl:template name="access-service"><xsl:choose><xsl:when test="@service"><xsl:value-of select="@service"/></xsl:when><xsl:otherwise>Access Nova Scotia</xsl:otherwise></xsl:choose></xsl:template>

<xsl:template name="access-fix-value"><!-- file contains markup encoded as text :S -->
  <xsl:param name="text"/>
  <xsl:choose>
    <xsl:when test="contains($text, '&lt;')"><xsl:value-of select="substring-before($text, '&lt;')"/><xsl:text>
    </xsl:text><xsl:call-template name="access-fix-value"><xsl:with-param name="text" select="substring-after($text, '&gt;')"/></xsl:call-template></xsl:when>
    <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="access:address">
  <xsl:variable name="place"><xsl:call-template name="access-place"/></xsl:variable>
  <xsl:variable name="service"><xsl:call-template name="access-service"/></xsl:variable>
  <xsl:call-template name="access-fix-value"><xsl:with-param name="text" select="$markers/marker[@name=$place and @service=$service]/@address"/></xsl:call-template>
</xsl:template>

<xsl:template match="access:hours">
  <xsl:variable name="place"><xsl:call-template name="access-place"/></xsl:variable>
  <xsl:variable name="service"><xsl:call-template name="access-service"/></xsl:variable>
  <xsl:call-template name="access-fix-value"><xsl:with-param name="text" select="$markers/marker[@name=$place and @service=$service]/@hours"/></xsl:call-template>
</xsl:template>

</xsl:transform>