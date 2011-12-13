<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns="http://www.w3.org/1999/xhtml"
               xmlns:html="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pg="http://gov.ns.ca/xmlns/page"
               exclude-result-prefixes="pg">
<xsl:import href="page.xsl"/>

<xsl:param name="lastmod" select="'20X6'"/>

<xsl:template match="pg:page" mode="meta">
  <xsl:apply-imports/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1"/>
</xsl:template>

<xsl:template match="pg:page" mode="css">
  <xsl:apply-imports/>
  <link rel="stylesheet" type="text/css" href="{$SITEROOT}/css/mobile.css" />
</xsl:template>

<xsl:template match="pg:page" mode="layout"><!-- default layout-->
	<div id="container">
	  <div id="header"><xsl:call-template name="header"/></div>
	  <div id="breadcrumbs"><xsl:call-template name="breadcrumbs"/></div>
		<div id="content"><xsl:call-template name="content"/></div>
		<div id="footer"><xsl:call-template name="footer"/></div>
	</div>
</xsl:template>

<xsl:template name="header">
		<a href="{$SITEROOT}/"><img id="vip" src="{$SITEROOT}/img/vip.svg" alt="Nova Scotia"/></a>
		<ul id="touchstone-links"><li class="touchstone-item"><a href="{$SITEROOT}/" class="touchstone-link">Home</a></li><!--li class="touchstone-item"><a href="fr" hreflang="fr" lang="fr" class="touchstone-link">Français</a></li--></ul>
</xsl:template>

<xsl:template match="html:html">
  <div class="box">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="pg:contentlinks">
  <ul class="boxList">
    <xsl:apply-templates/>
  </ul>
</xsl:template>

<xsl:template name="footer">
	<ul class="footer-nav">
	<li class="footerLink"><a href="{$SITEROOT}/contact/">Contact</a></li>
	<li class="footerLink"><a href="http://novascotia.ca/govt/privacy/">Privacy</a></li>
	<li class="footerLink"><a href="http://novascotia.ca/terms/">Terms of Use</a></li>
	<li class="footerLink"><a href="http://novascotia.ca">Full Site</a></li>
	</ul>
	<p class="site-meta">
		Copyright <xsl:value-of select="substring($lastmod, 1, 4)"/>, Province of Nova Scotia
	</p>
</xsl:template>

</xsl:transform>