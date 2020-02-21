<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:template match="/">
      <p:_post_set_batch_req xmlns:p="http://ws.wso2.org/dataservice">
         <xsl:for-each select="//csv-set/csv-record">
           <p:_put_update>
	     	 <p:product_id><xsl:value-of select="ProductID" /></p:product_id>               
             <p:change><xsl:value-of select="Change" /></p:change>              
             <p:location><xsl:value-of select="Location" /></p:location>
	     </p:_put_update>
         </xsl:for-each>
      </p:_post_set_batch_req>
   </xsl:template>
</xsl:stylesheet>

