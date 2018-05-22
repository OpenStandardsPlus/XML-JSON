<?xml version="1.0" encoding="UTF-8"?>
<!-- (c) 2018 Jason Polis -->
<!-- xml-to-json.xsl = converts xml to json retaining document order, where possible under the XSLT model.-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:err="http://www.w3.org/2005/xqt-errors" exclude-result-prefixes="array fn map math xhtml xs err" version="3.0" xmlns:j="http://www.w3.org/2013/XSLT/xml-to-json">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!-- W3C param -->
	<xsl:param name="indent-spaces" select="2"/>
	<!-- / -->
	<xsl:template match="/" name="xsl:initial-template">
		<OUTPUT>
			<XML>
				<xsl:copy-of select="@*|node()"/>
			</XML>
			<JSON>
[{"!--":"Transformation from XML to JSON using version Jason Polis 20180522g"}
<xsl:apply-templates select="@*|node()"/>
]
			</JSON>
		</OUTPUT>
	</xsl:template>
	<!-- ELEMENTS -->
	<xsl:template match="*">
		<xsl:param name="namespace-prefixes"/>
		<xsl:variable name="current-element" select="."/>
		<!-- write element name -->
,{"<xsl:value-of select="fn:name()"/>":[
<!-- METADATA (NAMESPACES, PSVI, etc) -->
		<xsl:text>[</xsl:text>
		<xsl:text>{</xsl:text>
		<!--DECLARATIONS -->
		<!-- declare new namespaces that are in current but not in parent -->
		<xsl:for-each select="fn:in-scope-prefixes(.)">
<!--{"DEBUG2":"<xsl:value-of select="."/>"}		
-->			<xsl:if test="not(. = $namespace-prefixes ) or fn:count($namespace-prefixes) = 1"><xsl:if test="fn:position() > 1">,</xsl:if>"xmlns:<xsl:value-of select="."/>":"<xsl:value-of select="fn:namespace-uri-for-prefix(.,$current-element)"/>"</xsl:if>
		</xsl:for-each>
		<!--UNDECLARATIONS-->
		<!-- undeclare namespaces that are in parent but not in current -->
		<xsl:for-each select="$namespace-prefixes">
			<xsl:if test="not(. = fn:in-scope-prefixes($current-element) )">
				<xsl:if test="fn:position() > 1">,</xsl:if>"xmlns:<xsl:value-of select="."/>":"<xsl:value-of select="fn:namespace-uri-for-prefix(.,$current-element)"/>"
</xsl:if>
		</xsl:for-each>
		<!-- DEBUG: list of current namespaces -->
<!--,{"DEBUG"
:{$namespace-prefixes":"<xsl:value-of select="$namespace-prefixes"/>"}
,{"namespace::*":"<xsl:value-of select="namespace::*"/>"}
,{"fn:in-scope-prefixes()":"<xsl:value-of select="fn:in-scope-prefixes(.)"/>"}
}
-->		<xsl:text>}</xsl:text>
		<!-- METADATA (ATTRIBUTES) -->
		<xsl:apply-templates select="@*"/>
		<xsl:text>]</xsl:text>
		<xsl:apply-templates select="*|text()|processing-instruction()|comment()">
			<xsl:with-param name="namespace-prefixes" select="fn:in-scope-prefixes(.)"/>
		</xsl:apply-templates>
	]}
</xsl:template>
	<!-- ATTRIBUTES -->
	<xsl:template match="@*">,{"<xsl:value-of select="fn:name(.)"/>":"<xsl:value-of select="."/>"}
</xsl:template>
	<!-- TEXT -->
	<xsl:template match="text()">
		<xsl:if test="fn:normalize-space(.)">,"<xsl:value-of select="j:escape(.)"/>"</xsl:if>
	</xsl:template>
	<!-- PI -->
	<xsl:template match="processing-instruction()">,{"?<xsl:value-of select="fn:name(.)"/>":"<xsl:value-of select="."/>"}
</xsl:template>
	<xsl:template match="comment()">,{"!--":"<xsl:value-of select="j:escape(.)"/>"}
</xsl:template>
	<!-- As per https://www.w3.org/TR/xslt-30/ -->
	<!-- Function to escape special characters -->
	<xsl:function name="j:escape" as="xs:string" visibility="final">
		<xsl:param name="in" as="xs:string"/>
		<xsl:value-of>
			<xsl:for-each select="string-to-codepoints($in)">
				<xsl:choose>
					<xsl:when test=". gt 65535">
						<xsl:value-of select="concat('\u', j:hex4((. - 65536) idiv 1024 + 55296))"/>
						<xsl:value-of select="concat('\u', j:hex4((. - 65536) mod 1024 + 56320))"/>
					</xsl:when>
					<xsl:when test=". = 34">\"</xsl:when>
					<xsl:when test=". = 92">\\</xsl:when>
					<xsl:when test=". = 08">\b</xsl:when>
					<xsl:when test=". = 09">\t</xsl:when>
					<xsl:when test=". = 10">\n</xsl:when>
					<xsl:when test=". = 12">\f</xsl:when>
					<xsl:when test=". = 13">\r</xsl:when>
					<xsl:when test=". lt 32 or (. ge 127 and . le 160)">
						<xsl:value-of select="concat('\u', j:hex4(.))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="codepoints-to-string(.)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:value-of>
	</xsl:function>
	<!-- Function to convert a UTF16 codepoint into a string of four hex digits -->
	<xsl:function name="j:hex4" as="xs:string" visibility="final">
		<xsl:param name="ch" as="xs:integer"/>
		<xsl:variable name="hex" select="'0123456789abcdef'"/>
		<xsl:value-of>
			<xsl:value-of select="substring($hex, $ch idiv 4096 + 1, 1)"/>
			<xsl:value-of select="substring($hex, $ch idiv 256 mod 16 + 1, 1)"/>
			<xsl:value-of select="substring($hex, $ch idiv 16 mod 16 + 1, 1)"/>
			<xsl:value-of select="substring($hex, $ch mod 16 + 1, 1)"/>
		</xsl:value-of>
	</xsl:function>
	<!-- Function to output whitespace indentation based on 
         the depth of the node supplied as a parameter -->
	<xsl:function name="j:indent" as="text()" visibility="public">
		<xsl:param name="depth" as="xs:integer"/>
		<xsl:value-of select="'&#xa;', string-join((1 to ($depth + 1) * $indent-spaces) ! ' ', '')"/>
	</xsl:function>
</xsl:stylesheet>
