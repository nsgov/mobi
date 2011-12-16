<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pg="http://gov.ns.ca/xmlns/page"
               xmlns:access="http://gov.ns.ca/xmlns/access-marker"
               xmlns:map="map"
               exclude-result-prefixes="pg access map">
<xsl:import href="../../xsl/mobilepage.xsl"/>

<xsl:variable name="markers" select="document('locations.xml')/markers"/>

<map:marker-labels>
  <map:marker-label attr="address" label="Address"/>
</map:marker-labels>

<xsl:template match="/pg:page" mode="css">
  <xsl:apply-imports/>
  <link rel="stylesheet" type="text/css" href="{$SITEROOT}/location/accessns/accessns.css"/>
</xsl:template>

<xsl:template match="pg:contentlinks">
  <h1 class="bucketHead"><img src="{$SITEROOT}/location/accessns/accessns-logo.png" alt="Access Nova Scotia"/></h1>
  <ul class="bucketList">
    <xsl:choose>
      <xsl:when test="@src">
        <xsl:apply-templates select="document(@src,.)/pg:contentlinks/pg:link"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="pg:link"/>
      </xsl:otherwise>
    </xsl:choose>
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
  <xsl:call-template name="access-fix-value"><xsl:with-param name="text" select="$markers/marker[@name=$place and @service=$service]/@*[local-name()=current()]"/></xsl:call-template>
</xsl:template>

<xsl:template match="access:centre">
  <xsl:variable name="place"><xsl:call-template name="access-place"/></xsl:variable>
  <xsl:variable name="service"><xsl:call-template name="access-service"/></xsl:variable>
  <xsl:if test="$markers/marker[@name=$place and @service=$service]">
    <h2><xsl:value-of select="$place"/> Access Centre</h2>
    <xsl:call-template name="access-centre">
      <xsl:with-param name="place" select="$place"/>
      <xsl:with-param name="service"><xsl:call-template name="access-service"/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="access-centre">
  <xsl:param name="place"/>
  <xsl:param name="service"/>
  <xsl:param name="centre" select="''"/>
  <xsl:variable name="marker" select="$markers/marker[@name=$place and @service=$service]"/>
  <dl class="access-centre">
    <xsl:if test="not($centre) or $marker/@address != $centre/@address">
      <dt>Address:</dt>
      <dd class="address"><xsl:call-template name="access-fix-value"><xsl:with-param name="text" select="$marker/@address"/></xsl:call-template></dd>
    </xsl:if>
    <xsl:if test="access:directions">
      <dt>Directions:</dt>
      <dd class="directions"><xsl:value-of select="access:directions"/></dd>
    </xsl:if>
    <xsl:if test="not($centre) or $marker/@phone != $centre/@phone or $marker/@tollfree != $centre/@tollfree">
      <dt>Phone:</dt>
      <xsl:call-template name="access-phone"><xsl:with-param name="num" select="$marker/@phone"/></xsl:call-template>
      <xsl:call-template name="access-phone"><xsl:with-param name="label" select="'Toll-free'"/><xsl:with-param name="num" select="$marker/@tollfree"/></xsl:call-template>
    </xsl:if>
    <xsl:if test="not($centre) or $marker/@hours != $centre/@hours">
      <dt>Hours:</dt>
      <dd class="hours"><xsl:call-template name="access-fix-value"><xsl:with-param name="text" select="$marker/@hours"/></xsl:call-template></dd>
    </xsl:if>
    <xsl:if test="$marker/@details">
      <xsl:if test="not($centre) or $marker/@details != $centre/@details">
      <dt>Details:</dt>
      <dd class="details"><a href="{$marker/@details}"><xsl:value-of select="$marker/@details"/></a></dd>
      </xsl:if>
    </xsl:if>
  </dl>
</xsl:template>

<xsl:template name="access-phone">
  <xsl:param name="label"/>
  <xsl:param name="num"/>
  <xsl:variable name="n" select="translate($num, '. +-()', '')"/>
  <xsl:variable name="l" select="string-length($n)"/>
  <xsl:variable name="href"><xsl:choose>
    <xsl:when test="$l=7">tel:+1902<xsl:value-of select="$n"/></xsl:when>
    <xsl:when test="$l=10">tel:+1<xsl:value-of select="$n"/></xsl:when>
    <xsl:when test="$l=11 and starts-with($n, '1')">tel:+<xsl:value-of select="$n"/></xsl:when>
  </xsl:choose></xsl:variable>
  <xsl:if test="string-length($num) and $num!='n/a'">
    <dd class="phone"><xsl:choose>
      <xsl:when test="string-length($href)"><a href="{$href}"><xsl:value-of select="$num"/></a></xsl:when>
      <xsl:otherwise><xsl:value-of select="$num"/></xsl:otherwise>
    </xsl:choose><xsl:if test="$label"> (<xsl:value-of select="$label"/>)</xsl:if></dd>
  </xsl:if>
</xsl:template>

<xsl:template match="access:services">
  <xsl:variable name="place"><xsl:call-template name="access-place"/></xsl:variable>
  <xsl:variable name="accesscentre" select="$markers/marker[@name=$place and @service='Access Nova Scotia']"/>
  <xsl:if test="$markers/marker[@name=$place and @service!='Access Nova Scotia']">
    <h2><xsl:value-of select="$place"/> Services</h2>
    <ul>
      <xsl:for-each select="$markers/marker[@name=$place and @service!='Access Nova Scotia']">
        <li class="access-service">
          <h3><xsl:value-of select="@service"/></h3>
          <xsl:call-template name="access-centre">
            <xsl:with-param name="place" select="$place"/>
            <xsl:with-param name="service" select="@service"/>
            <xsl:with-param name="centre" select="$accesscentre"/>
          </xsl:call-template>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:if>
</xsl:template>

<xsl:template name="access-centre-field">
  <xsl:param name="marker"/>
  <xsl:param name="field"/>
  <xsl:variable name="attr" select="$marker/@*[current()=$field]"/>
  <xsl:variable name="value"><xsl:choose>
    <xsl:when test="$attr and string-length($attr) and $attr!='n/a'"><xsl:value-of select="$attr"/></xsl:when>
    <xsl:when test="access:*[local-name()=$field]"><xsl:value-of select="access:*[local-name()=$field]"/></xsl:when>
  </xsl:choose></xsl:variable>
  <dt class="{$field}"><xsl:value-of select="$field"/></dt>
  <dd class="${field}"><xsl:call-template name="access-fix-value"><xsl:with-param name="text" select="$value"/></xsl:call-template></dd>
</xsl:template>

</xsl:transform>