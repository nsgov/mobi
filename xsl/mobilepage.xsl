<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pg="http://gov.ns.ca/xmlns/page"
               exclude-result-prefixes="pg">
<xsl:import href="page.xsl"/>

<xsl:template match="pg:page" mode="meta">
  <xsl:apply-imports/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1"/>
</xsl:template>

<xsl:template match="pg:page" mode="css">
  <xsl:apply-imports/>
  <link rel="stylesheet" type="text/css" href="/css/mobile.css" />
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
		<img id="vip" src="/img/vip.svg"/>
		<ul id="touchstone-links"><li class="touchstone-link">Home</li><li class="touchstone-link">Français</li></ul>
</xsl:template>

<xsl:template match="pg:contentlinks">
  <ul class="boxList">
    <xsl:apply-templates/>
  </ul>
</xsl:template>

<xsl:template name="footer">
	<ul class="footer-nav">
	<li class="footerLink"><a href="">Contact</a></li>
	<li class="footerLink"><a href="">Privacy</a></li>
	<li class="footerLink"><a href="">Terms of Use</a></li>
	<li class="footerLink"><a href="">Full Site</a></li>
	</ul>
	<p class="site-meta">
		Copyright 2011, Province of Nova Scotia
	</p>
</xsl:template>

</xsl:transform>