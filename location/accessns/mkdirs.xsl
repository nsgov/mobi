<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns:pg="http://gov.ns.ca/xmlns/page"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8" indent="yes" method="text" />

<xsl:template match="/pg:contentlinks">
mklocation() {
    ID="$1"
    TITLE="$2"
    FILE="$ID/$ID.xml"
    [ -d "$ID" ] || mkdir "$ID"
    [ -f "$FILE" ] || sed "s~TITLE~$TITLE~g" &lt; newlocation.xml &gt; "$FILE"
    [ -f "$ID/Makefile" ] || cp newlocation.mk "$ID/Makefile"
}
<xsl:for-each select="pg:link"
>mklocation "<xsl:value-of select="@page"/>" "<xsl:value-of select="@title"/>"
</xsl:for-each>

</xsl:template>

</xsl:transform>

