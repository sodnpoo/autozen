<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xhtml="http://www.w3.org/1999/xhtml"
 xmlns:str="http://exslt.org/strings"
>
<!--
-->
<xsl:output omit-xml-declaration="yes" indent="no" method="text"/>
<xsl:strip-space elements="*"/>

<xsl:param name="domain"/>

<xsl:template match="/">
  <xsl:apply-templates select="//xhtml:div[@class = 'OrderItemReference']"/><xsl:text></xsl:text>
</xsl:template>

<xsl:template match="xhtml:div">
  <!-- we're expecting to find a 'Friendly Name' set in the format: 'Friendly Name: sodnpoo.co.uk' -->
  <xsl:if test="str:tokenize(.)[3] = $domain">
    <xsl:for-each select="following-sibling::*[@class = 'CssButtons']">
      <xsl:for-each select="descendant::*[name(.) = 'a']">https://portal.zen.co.uk<xsl:value-of select="@href" />
      </xsl:for-each>
    </xsl:for-each>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
