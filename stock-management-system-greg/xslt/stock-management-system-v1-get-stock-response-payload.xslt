<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:ns="http://ws.wso2.org/dataservice" exclude-result-prefixes="ns">
	<xsl:template match="/">
	<payload>
	<xsl:text>[</xsl:text>
	<xsl:text>&#10;</xsl:text>
	<xsl:for-each select="//*/ns:message">
    <xsl:text>{</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text> "ProductID": "</xsl:text><xsl:value-of select="ns:product_id" /><xsl:text>",</xsl:text>
    <xsl:text> "ProductName": "</xsl:text><xsl:value-of select="ns:product_name" /><xsl:text>",</xsl:text>
    <xsl:text> "Stock": {</xsl:text>
      <xsl:text> "Amount": "</xsl:text><xsl:value-of select="ns:stock_level" /><xsl:text>",</xsl:text>
      <xsl:text> "Location": "</xsl:text><xsl:value-of select="ns:location" /><xsl:text>"</xsl:text>
	<xsl:text> }</xsl:text>
	<xsl:text> }</xsl:text>
	<xsl:if test="position() != last()">
	  <xsl:text>,</xsl:text>
	</xsl:if>
	</xsl:for-each>
	<xsl:text>]</xsl:text>
	</payload>
	</xsl:template>
</xsl:stylesheet>

