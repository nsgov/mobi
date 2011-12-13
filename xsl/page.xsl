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

<xsl:variable name="path_xml" select="document('.path.xml', .)"/>
<xsl:param name="lang"/>
<xsl:param name="SITEROOT" select="$path_xml/path/@root"/>

<xsl:template match="/pg:page">
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text-->
<html version="XHTML+RDFa 1.0" xmlns="http://www.w3.org/1999/xhtml" lang="{$lang}" xml:lang="{$lang}">
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8"/>
    <title><xsl:apply-templates select="pg:title[@lang=$lang or not(@lang)]"/></title>
    <xsl:apply-templates select="." mode="meta"/>
    <xsl:apply-templates select="." mode="css"/>
    <xsl:apply-templates select="pg:css"/>
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
	  <span class="whereareyou">You are here:</span>
	  <ol xmlns:v="http://rdf.data-vocabulary.org/#">
      <li typeof="v:Breadcrumb"><a href="{$SITEROOT}/" class="breadcrumblink" rel="v:url" property="v:title">Home</a></li>
	    <xsl:apply-templates select="@breadcrumb"/>
	  </ol>
</xsl:template>
<xsl:template match="@breadcrumb">
  <xsl:param name="href"/>
  <xsl:variable name="parentid" select="string(document(concat(., '/.path.xml'),.)/path/@basename)"/>
  <xsl:variable name="parentxml" select="concat(., '/', $parentid, '.xml')"/>
  <xsl:if test="$parentid and $parentid != ''">
    <xsl:apply-templates select="document($parentxml,.)/pg:page/@breadcrumb">
      <xsl:with-param name="href" select="concat($href, ., '/')"/>
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
  <xsl:variable name="file"><xsl:call-template name="path-to-page-xml"><xsl:with-param name="path" select="@page"/></xsl:call-template></xsl:variable>
  <xsl:variable name="href"><xsl:choose><xsl:when test="$lang=''"><xsl:value-of select="$file"/></xsl:when><xsl:otherwise><xsl:value-of select="@page"/>/<xsl:if test="not($lang='en')"><xsl:value-of select="$lang"/></xsl:if></xsl:otherwise></xsl:choose></xsl:variable>
  <xsl:variable name="doctitle"><xsl:value-of select="document($file,.)/pg:page/pg:title[@lang=$lang or not(@lang)]"/></xsl:variable>
  <xsl:variable name="title"><xsl:choose><xsl:when test="string-length($doctitle)"><xsl:value-of select="$doctitle"/></xsl:when><xsl:otherwise><xsl:value-of select="@page"/></xsl:otherwise></xsl:choose></xsl:variable>
  <li><a href="{$href}" class="content-link"><xsl:value-of select="$title"/></a></li>
</xsl:template>

<xsl:template match="html:html">
  <!--xsl:copy-of select="node()"/-->
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="html:*|@*">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="pg:css">
  <link rel="stylesheet" href="{@href}" type="text/css">
    <xsl:if test="@media"><xsl:attribute name="media"><xsl:value-of select="@media"/></xsl:attribute></xsl:if>
  </link>
</xsl:template>

<xsl:template match="pg:script">
  <script type="text/javascript" src="{@src}"><xsl:text/></script>
</xsl:template>

<xsl:template name="path-to-page-xml">
  <xsl:param name="path" select="'.'"/>
  <xsl:param name="trail"/>
  <xsl:variable name="path1" select="substring-before($path, '/')"/>
  <xsl:variable name="path2" select="substring-after($path, '/')"/>
  <xsl:choose>
    <xsl:when test="$path='' or $path='.'"><xsl:value-of select="concat($trail,document(concat($trail,'.path.xml'),.)/path/@basename)"/>.xml</xsl:when>
    <xsl:when test="$path='..'"><xsl:value-of select="concat($path,'/', document(concat($path,'/.path.xml'),.)/path/@basename)"/>.xml</xsl:when>
    <xsl:when test="not(contains($path, '/'))"><xsl:value-of select="concat($trail,$path,'/',$path)"/>.xml</xsl:when>
    <xsl:when test="substring($path, 1, 1) = '/'"><xsl:call-template name="path-to-page-xml"><xsl:with-param name="path" select="$path2"/><xsl:with-param name="trail" select="concat($path_xml/path/@root, '/')"/></xsl:call-template></xsl:when>
    <xsl:otherwise><xsl:call-template name="path-to-page-xml"><xsl:with-param name="path" select="$path2"/><xsl:with-param name="trail" select="concat($trail,$path1,'/')"/></xsl:call-template></xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:transform>
