<?xml version="1.0" encoding="UTF-8" ?>
<!--
	xsldeps
	Created by David Nordlund on 2011-10-03.
	
	Given an xsl file, or an xml file with an xml-stylesheet PI,
	find all the xsl dependencies by recursively going through xsl:include & xsl:import elements,
	and output the list of filenames.
	Useful for creating a dependency list for a Makefile.
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="UTF-8" indent="no" method="text" />

  <xsl:param name="abspath"/><!-- Prefix $abspath to any /absolute/file.paths in the output.  Not usually needed. -->
  <xsl:param name="relpath"/><!-- Relative paths in the output should be relative to $path.  Use if initial file is not in pwd. -->

  <xsl:template match="processing-instruction('xml-stylesheet')">
      <xsl:variable name="cut1" select="substring-after(string(.), 'href=')"/>
      <xsl:variable name="cut2" select="substring($cut1, 2)"/>
      <xsl:variable name="q" select="substring($cut1, 1, 1)"/>
      <xsl:call-template name="dependency">
        <xsl:with-param name="currentpath" select="$relpath"/>
        <xsl:with-param name="href" select="substring-before($cut2, $q)"/>
      </xsl:call-template>
  </xsl:template>

	<xsl:template match="xsl:import|xsl:include">
	  <xsl:param name="currentpath" select="$relpath"/>
    <xsl:call-template name="dependency">
      <xsl:with-param name="currentpath" select="$currentpath"/>
      <xsl:with-param name="href" select="@href"/>
    </xsl:call-template>
	</xsl:template>

  <xsl:template name="dependency">
    <xsl:param name="currentpath"/>
    <xsl:param name="href"/>
	  <xsl:variable name="resolvedpath"><xsl:call-template name="resolve-path">
	    <xsl:with-param name="src" select="$currentpath"/>
	    <xsl:with-param name="dest" select="$href"/>
	  </xsl:call-template></xsl:variable>
	  <xsl:value-of select="$resolvedpath"/><xsl:text>&#10;</xsl:text>
	  <xsl:apply-templates select="document($href,.)"><xsl:with-param name="currentpath" select="$resolvedpath"/></xsl:apply-templates>
  </xsl:template>

	<xsl:template name="dirname"><!-- Given a path to a file or directory, output the parent path (mimic the unix dirname function) -->
	  <xsl:param name="path"/>
	  <xsl:if test="contains($path, '/')">
	    <xsl:value-of select="substring-before($path,'/')"/>/<xsl:call-template name="dirname"><xsl:with-param name="path" select="substring-after($path, '/')"/></xsl:call-template>
	  </xsl:if>
	</xsl:template>
	
	<xsl:template name="resolve-path"><!-- output a path to $dest starting from $src -->
	  <xsl:param name="src" select="'.'"/>
	  <xsl:param name="dest"/>
	  <xsl:choose>
	    <xsl:when test="starts-with($dest, '/')"><xsl:value-of select="$abspath"/></xsl:when><!-- absolute path -->
	    <xsl:when test="contains($dest, ':')"/><!-- a url most likely -->
	    <xsl:otherwise><xsl:call-template name="dirname"><xsl:with-param name="path" select="$src"/></xsl:call-template></xsl:otherwise>
	  </xsl:choose><xsl:value-of select="$dest"/>
	</xsl:template>
	  
  <xsl:template match="text()"/>

</xsl:transform>
