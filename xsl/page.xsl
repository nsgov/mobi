<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns="http://www.w3.org/1999/xhtml"
               xmlns:html="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pg="http://gov.ns.ca/xmlns/page"
               exclude-result-prefixes="html pg">
<xsl:output encoding="utf-8" indent="yes" method="xml"
            doctype-public="-//W3C//DTD XHTML+RDFa 1.0//EN"
            doctype-system="http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"
            omit-xml-declaration="yes"/>

<xsl:param name="lang"/>

<xsl:template match="/pg:page">
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text-->
<html version="XHTML+RDFa 1.0" xmlns="http://www.w3.org/1999/xhtml" lang="{$lang}" xml:lang="{$lang}">
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8"/>
    <title><xsl:apply-templates select="pg:title[@lang=$lang or not(@lang)]"/></title>
    <xsl:apply-templates select="." mode="meta"/>
    <xsl:apply-templates select="." mode="css"/>
  </head>
  <body>
    <xsl:apply-templates select="." mode="layout"/>
    <xsl:apply-templates select="pg:script"/>
  </body>
</html>
</xsl:template>

<xsl:template match="pg:title"><xsl:value-of select="."/> - Gov NS</xsl:template>

<xsl:template name="shorttitle">
  <xsl:choose>
    <xsl:when test="/pg:page/pg:title[@lang=$lang or not(@lang)]/@abbr">
      <xsl:value-of select="/pg:page/pg:title[@lang=$lang or not(@lang)]/@abbr"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="/pg:page/pg:title[@lang=$lang or not(@lang)]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="breadcrumbs">
  <xsl:if test="@breadcrumb">
	  <span class="whereareyou">You are here:</span>
	  <ol xmlns:v="http://rdf.data-vocabulary.org/#">
      <li typeof="v:Breadcrumb"><a href="/" class="breadcrumblink" rel="v:url" property="v:title">Home</a></li>
	    <xsl:apply-templates select="@breadcrumb"/>
	  </ol>
	</xsl:if>
</xsl:template>
<xsl:template match="@breadcrumb">
  <xsl:param name="href"/>
  <xsl:variable name="parentid" select="concat(document(concat(., '.id.xml'),.)/id/text(), '')"/>
  <xsl:variable name="parentxml" select="concat(., $parentid, '.xml')"/>
  <xsl:if test="$parentid and $parentid != ''">
    <xsl:apply-templates select="document($parentxml,.)/pg:page/@breadcrumb">
      <xsl:with-param name="href" select="concat($href, .)"/>
    </xsl:apply-templates>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="$href != ''">
      <li typeof="v:Breadcrumb"><a href="{$href}" class="breadcrumblink" rel="v:url" property="v:title"><xsl:call-template name="shorttitle"/></a></li>
    </xsl:when>
    <xsl:otherwise>
      <li><span class="breadcrumbhere"><xsl:call-template name="shorttitle"/></span></li>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="content">
  <xsl:apply-templates select="pg:content[@lang=$lang or not(@lang)]"/>
</xsl:template>

<xsl:template match="pg:content">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="pg:link[@page]">
  <xsl:variable name="file"><xsl:value-of select="@page"/>/<xsl:value-of select="@page"/>.xml</xsl:variable>
  <xsl:variable name="href"><xsl:choose><xsl:when test="$lang=''"><xsl:value-of select="$file"/></xsl:when><xsl:otherwise><xsl:value-of select="@page"/>/</xsl:otherwise></xsl:choose></xsl:variable>
  <xsl:variable name="doctitle"><xsl:value-of select="document($file,.)/pg:page/pg:title"/></xsl:variable>
  <xsl:variable name="title"><xsl:choose><xsl:when test="string-length($doctitle)"><xsl:value-of select="$doctitle"/></xsl:when><xsl:otherwise><xsl:value-of select="@page"/></xsl:otherwise></xsl:choose></xsl:variable>
  <li><a href="{$href}" class="content-link"><xsl:value-of select="$title"/></a></li>
</xsl:template>

<xsl:template match="html:html">
  <xsl:copy-of select="node()"/>
</xsl:template>

<xsl:template match="pg:script">
  <script type="text/javascript" src="{@src}"><xsl:text/></script>
</xsl:template>

</xsl:transform>
