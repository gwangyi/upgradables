<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="//*[local-name()='html']">
    </xsl:template>
    <xsl:template match="//*[local-name()='feed']/*">
    </xsl:template>
    <xsl:template match="//*[local-name()='feed']/*[local-name()='entry']">
        <xsl:value-of select="*[local-name()='author']/*[local-name()='name']"/>: <xsl:value-of select="*[local-name()='title']/text()"/><xsl:text>&#xa;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
