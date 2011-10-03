<?xml version="1.0" encoding="UTF-8" ?>
<!--
	xsldeps
	Created by David Nordlund on 2011-10-03.
	
	Given an xsl file, or an xml file with an xml-stylesheet PI,
	find all the xsl dependencies, by tracking through the xsl:include & xsl:import elements,
	and output the list of filenames.
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="UTF-8" indent="no" method="text" />

  <xsl:param name="root"/>
  <xsl:param name="path" select="'.'"/>

  <xsl:template match="text()"/>

  <xsl:template match="processing-instruction('xml-stylesheet')">
      <xsl:variable name="cut1" select="substring-after(string(.), 'href=')"/>
      <xsl:variable name="q" select="substring($cut1, 1, 1)"/>
      <xsl:variable name="cut2" select="substring($cut1, 2)"/>
      <xsl:variable name="href" select="substring-before($cut2, $q)"/>
      <xsl:variable name="resolvedpath"><xsl:call-template name="resolve-path">
        <xsl:with-param name="src" select="$path"/>
        <xsl:with-param name="dest" select="$href"/>
      </xsl:call-template></xsl:variable>
      <xsl:value-of select="$resolvedpath"/><xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select="document($href,.)/*"><xsl:with-param name="path" select="$resolvedpath"/></xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="/xsl:transform|/xsl:stylesheet">
    <xsl:param name="path"/>
    <xsl:apply-templates select="xsl:import|xsl:include">
      <xsl:with-param name="path" select="$path"/>
    </xsl:apply-templates>
  </xsl:template>

	<xsl:template match="xsl:import|xsl:include">
	  <xsl:param name="path" select="'.'"/>
	  <xsl:variable name="q">"</xsl:variable>
	  <xsl:variable name="resolvedpath"><xsl:call-template name="resolve-path">
	    <xsl:with-param name="src" select="$path"/>
	    <xsl:with-param name="dest" select="@href"/>
	  </xsl:call-template></xsl:variable>
	  <xsl:value-of select="$resolvedpath"/><xsl:text>&#10;</xsl:text>
	  <xsl:apply-templates select="document(@href,.)/*"><xsl:with-param name="path" select="$resolvedpath"/></xsl:apply-templates>
	</xsl:template>

  <xsl:template name="dirname-container">
    <xsl:param name="path"/>
    <xsl:variable name="d"><xsl:call-template name="dirname-recursive"><xsl:with-param name="path" select="$path"/></xsl:call-template></xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($d)"><xsl:value-of select="$d"/></xsl:when>
      <xsl:otherwise>.</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

	<xsl:template name="dirname">
	  <xsl:param name="path"/>
	  <xsl:if test="contains($path, '/')"><xsl:value-of select="substring-before($path,'/')"/>/<xsl:call-template name="dirname">
	    <xsl:with-param name="path"><xsl:value-of select="substring-after($path, '/')"/>
	  </xsl:with-param></xsl:call-template></xsl:if>
	</xsl:template>
	
	<xsl:template name="resolve-path">
	  <xsl:param name="src" select="'.'"/>
	  <xsl:param name="dest"/>
	  <xsl:choose>
	    <xsl:when test="starts-with($dest, '/')"><xsl:value-of select="$root"/></xsl:when><!-- absolute path -->
	    <xsl:when test="contains($dest, ':')"/><!-- a url most likely -->
	    <xsl:otherwise><xsl:call-template name="dirname"><xsl:with-param name="path" select="$src"/></xsl:call-template></xsl:otherwise>
	  </xsl:choose><xsl:value-of select="$dest"/>
	</xsl:template>
	  
</xsl:transform>