<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:template match="/">
      <p:_post_set_batch_req xmlns:p="http://ws.wso2.org/dataservice">
         <xsl:for-each select="//*[local-name()='jsonElement']">
            <p:_post_set>
               <p:product_id>
                  <xsl:value-of select="ProductID" />
               </p:product_id>
               <xsl:if test="ProductName/text()">
                  <p:product_name>
                     <xsl:value-of select="ProductName" />
                  </p:product_name>
               </xsl:if>
               <p:stock_level>
                  <xsl:value-of select="Stock/Amount" />
               </p:stock_level>
               <p:location>
                  <xsl:value-of select="Stock/Location" />
               </p:location>
            </p:_post_set>
         </xsl:for-each>
      </p:_post_set_batch_req>
   </xsl:template>
</xsl:stylesheet>
