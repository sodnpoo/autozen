<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xhtml="http://www.w3.org/1999/xhtml"
 xmlns:str="http://exslt.org/strings"
>
<!--
*** this file transforms the <input> tags in the zen portal page into form post data suitable for curl to use
*** this deals with the asp viewstate crap...(hopefully)
-->
<xsl:output omit-xml-declaration="yes" indent="no" method="text"/>
<xsl:strip-space elements="*"/>

<xsl:param name="ip1"/>
<xsl:param name="ip2"/>
<xsl:param name="ip3"/>
<xsl:param name="ip4"/>
<xsl:param name="ttl"/>

<xsl:template match="/"><xsl:apply-templates select="//xhtml:input"/>DNSTools_SelectOption_Web=ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$DNSTools_SelectOption_Web_IPAddress&#38;DNSTools_SelectOption_EMail=ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$DNSTools_SelectOption_EMail_None
<xsl:text></xsl:text>
</xsl:template>

<xsl:template match="xhtml:input">
<!--
  <xsl:value-of select="@name"/>=<xsl:value-of select="@value"/>&#38;<xsl:text></xsl:text>
-->  

  <xsl:choose>

    <xsl:when test="@name = '__EVENTTARGET'">
      <xsl:value-of select="@name"/>=ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$styleTTLRecords$ctl01$rptTTLRecords$ctl00$btnTTLRecordEdit&#38;<xsl:text></xsl:text>
    </xsl:when>

    <!-- these are set in the JS so we need to set them by hand -->
    <xsl:when test="@name = 'DNSTools_SelectOption_Web'"></xsl:when>
    <xsl:when test="@name = 'DNSTools_SelectOption_EMail'"></xsl:when>
    <xsl:when test="@name = 'ctl00$ctl00$Search$btnTopSearch'"></xsl:when>
    
    <!-- poke our values in -->
    <xsl:when test="@name = 'ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$txtWebIPPart1$ZenTextBox'">
      <xsl:value-of select="@name"/>=<xsl:value-of select="$ip1"/>&#38;<xsl:text></xsl:text>
    </xsl:when>
    <xsl:when test="@name = 'ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$txtWebIPPart2$ZenTextBox'">
      <xsl:value-of select="@name"/>=<xsl:value-of select="$ip2"/>&#38;<xsl:text></xsl:text>
    </xsl:when>
    <xsl:when test="@name = 'ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$txtWebIPPart3$ZenTextBox'">
      <xsl:value-of select="@name"/>=<xsl:value-of select="$ip3"/>&#38;<xsl:text></xsl:text>
    </xsl:when>
    <xsl:when test="@name = 'ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$txtWebIPPart4$ZenTextBox'">
      <xsl:value-of select="@name"/>=<xsl:value-of select="$ip4"/>&#38;<xsl:text></xsl:text>
    </xsl:when>
    
    <xsl:when test="@name = 'ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$styleTTLRecords$ctl01$rptTTLRecords$ctl00$txtTTLCurrentValueEdit$ZenTextBox'">
      <xsl:value-of select="@name"/>=<xsl:value-of select="$ttl"/>&#38;<xsl:text></xsl:text>
    </xsl:when>

    <xsl:when test="@name = 'ctl00$ctl00$ContentPlaceholderColumnTwo$ContentPlaceholderPageContent$PageContentControl$ProductModuleControl$styleTTLRecords$ctl01$rptTTLRecords$ctl00$txtTTLNewValueEdit$ZenTextBox'">
      <xsl:value-of select="@name"/>=<xsl:value-of select="$ttl"/>&#38;<xsl:text></xsl:text>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="@name"/>=<xsl:value-of select="str:encode-uri(@value ,true())"/>&#38;<xsl:text></xsl:text>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

</xsl:stylesheet>
