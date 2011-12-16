<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" indent="yes" method="xml" />

<xsl:template match="/markers">
  <xsl:variable name="cut"> _-'</xsl:variable>
  <contentlinks xmlns="http://gov.ns.ca/xmlns/page">
    <xsl:for-each select="marker">
      <xsl:sort select="@name"/>
      <link page="{translate(@name, $cut, '')}" title="{@name}"/>
    </xsl:for-each>
  </contentlinks>
</xsl:template>

</xsl:transform>
