<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pg="http://gov.ns.ca/xmlns/page"
               exclude-result-prefixes="pg">
<xsl:import href="xsl/mobilepage.xsl"/>

<xsl:template match="pg:contentlinks">
  <div id="nav">
  <ul>
    <xsl:apply-templates/>
  </ul>
  </div>
</xsl:template>


</xsl:transform>