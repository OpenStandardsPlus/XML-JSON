<?xml version="1.0" encoding="UTF-8"?>
<!-- (c) 2018 Jason Polis -->
<!-- json-to-xml.xsl = converts json+metadata retaining document order to xml, where possible under the XSLT3 model.-->
<xsl:stylesheet xmlns="http://www.w3.org/2005/xpath-functions" xpath-default-namespace="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:err="http://www.w3.org/2005/xqt-errors" exclude-result-prefixes="array fn map math xhtml xs err" version="3.0">
	<!---->
	<xsl:mode on-no-match="shallow-copy"/>
	<xsl:param name="input"/>
	<xsl:output method="xml" indent="yes"/>
	<!-- / -->
	<xsl:template match="/" name="xsl:initial-template">
		<ROOT>
			<OUTPUT>
				<xsl:apply-templates select="fn:json-to-xml(/)/array/*"/>
			</OUTPUT>
			<INPUT-AS-XML>
				<xsl:copy-of select="fn:json-to-xml(/)"/>
			</INPUT-AS-XML>
			<INPUT>
				<xsl:value-of select="."/>
			</INPUT>
		</ROOT>
	</xsl:template>
	<!-- COMMENT -->
	<xsl:template match="map[string[@key='!--']]">
		<xsl:comment select="string"/>
	</xsl:template>
	<!-- PI -->
	<xsl:template match="map[string[fn:starts-with(@key,'?')]]">
		<xsl:variable name="pi-name" select="fn:substring(string/@key,2)"/>
		<xsl:processing-instruction name="{fn:substring(string/@key,2)}" select="string"/>
	</xsl:template>
	<!-- PLACEHOLDER = for metadata like PSVI -->
	<xsl:template match="map[string[@key='']]"/>
	<!-- ELEMENT -->
	<xsl:template match="map[array[@key]]">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="array[@key]">
		<xsl:element name="{@key}">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<!-- ATTRIBUTE & NAMESPACE -->
	<xsl:template match="array/array[1]">
		<xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
		<xsl:for-each select="map/string">
			<xsl:choose>
				<!-- NAMESPACE -->
				<xsl:when test="@key=''"/>
				<xsl:when test="@key='xmlns:'">
					<!-- XSL3 prohibits explicit namespace undeclaration -->
				</xsl:when>
				<xsl:when test="@key='xmlns:xml'">
					<!-- XSL3 prohibits xml namespace declaration -->
				</xsl:when>
				<xsl:when test="fn:substring-after(@key,'xmlns:')">
					<xsl:choose>
						<xsl:when test="string-length(text()) = 0"/>
						<xsl:otherwise>
							<xsl:namespace name="{fn:substring-after(@key,'xmlns:')}" select="text()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- ATTRIBUTE -->
					<xsl:choose>
						<xsl:when test="fn:contains(@key,':')">
							<xsl:variable name="my-prefix" select="fn:substring-before(@key,':')"/>
							<xsl:variable name="my-namespace" select="ancestor-or-self::array/array/map/string[fn:starts-with(@key,'xmlns:')][$my-prefix = substring-after(@key,':')][1]/text()"/>
<!-- DEBUG for namespace prefix lookup
							<xsl:message select="'p='||$my-prefix ||' ns='|| $my-namespace||'.'"/>
-->							<xsl:attribute name="{fn:substring-after(@key,':')}" select="text()" namespace="{$my-namespace}"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="{@key}" select="text()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!-- TEXT -->
	<xsl:template match="map/array/string">
		<xsl:value-of select="."/>
	</xsl:template>
</xsl:stylesheet>
