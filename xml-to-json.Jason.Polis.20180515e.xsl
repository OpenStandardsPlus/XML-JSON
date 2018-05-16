<?xml version="1.0" encoding="UTF-8"?>
<!-- (c) 2018 Jason Polis -->
<!-- xml-to-json.xsl = converts xml to json retaining document order, where possible under the XSLT model.-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:err="http://www.w3.org/2005/xqt-errors" exclude-result-prefixes="array fn map math xhtml xs err" version="3.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/" name="xsl:initial-template">
		<OUTPUT>
			<XML>
				<xsl:copy-of select="@*|node()"/>
			</XML>
			<JSON>
[{"!--":"Transformation from XML to JSON using version Jason Polis 20180515e"}
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
	[ 
	<!-- DEBUG: list of current namespaces -->
<!--	{"namespace::*":"<xsl:value-of select="namespace::*"/>"}
	{"fn:in-scope-prefixes()":"<xsl:value-of select="fn:in-scope-prefixes(.)"/>"}
-->	<!-- undeclare namespaces that are in parent but not in current -->
{<!--UNDEC--><xsl:for-each select="$namespace-prefixes"><xsl:if test="not(. = fn:in-scope-prefixes($current-element) )">,"xmlns:<xsl:value-of select="."/>":"<xsl:value-of select="fn:namespace-uri-for-prefix(.,$current-element)"/>"
</xsl:if></xsl:for-each>
<!-- declare new namespaces that are in current but not in parent -->
<!--DEC--><xsl:for-each select="fn:in-scope-prefixes(.)"><xsl:if test="not(. = $namespace-prefixes )">,"xmlns:<xsl:value-of select="."/>":"<xsl:value-of select="fn:namespace-uri-for-prefix(.,$current-element)"/>"</xsl:if>
</xsl:for-each>}
	<xsl:apply-templates select="@*"/>]
	<xsl:apply-templates select="*|text()|processing-instruction()|comment()">
			<xsl:with-param name="namespace-prefixes" select="fn:in-scope-prefixes(.)"/>
		</xsl:apply-templates>
	]}
</xsl:template>
	<!-- ATTRIBUTES -->
	<xsl:template match="@*">,{"<xsl:value-of select="fn:name(.)"/>":"<xsl:value-of select="."/>"}
</xsl:template>
	<!-- TEXT -->
	<xsl:template match="text()">,"<xsl:copy/>"
</xsl:template>
	<!-- PI -->
	<xsl:template match="processing-instruction()">,{"?<xsl:value-of select="fn:name(.)"/>":"<xsl:value-of select="."/>"}
</xsl:template>
	<xsl:template match="comment()">,{"!--":"<xsl:value-of select="."/>"}
</xsl:template>
</xsl:stylesheet>
