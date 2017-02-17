<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:html="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html" version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple markdown file from TEI XML input</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:include href="Tei2Md-functions.xsl"/>

    <!-- save as new file -->
    <xsl:template match="/">
        <xsl:result-document href="../md/{$vFileId}.md">
            <xsl:apply-templates/>
        </xsl:result-document>
    </xsl:template>

    <!-- provide a YAML header -->
    <xsl:template match="tei:teiHeader">
        <xsl:variable name="vLang" select="'ar'"/>
        <xsl:variable name="vSourceBibl" select="./tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
        <xsl:variable name="vPubTitle" select="$vSourceBibl/tei:monogr/tei:title[@xml:lang=$vLang][not(@type='sub')][1]"/>
<!--        <xsl:variable name="vAuthor1" select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]"/>-->
        <xsl:variable name="vAuthor">
            <xsl:choose>
                <xsl:when test="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:surname">
                    <xsl:value-of select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:surname"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]/tei:forename"/>
                </xsl:when>
                <xsl:when test="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]">
                    <xsl:value-of select="$vSourceBibl/tei:monogr/tei:editor/tei:persName[@xml:lang=$vLang]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vPubDate" select="$vSourceBibl/tei:monogr/tei:imprint/tei:date[1]/@when"/>
<xsl:text>---
</xsl:text>
<xsl:text>title: "</xsl:text><xsl:value-of select="$vPubTitle"/><xsl:text>"</xsl:text>
<xsl:text>
author: </xsl:text><xsl:value-of select="$vAuthor"/>
<xsl:text>
date: </xsl:text><xsl:value-of select="$vPubDate"/>
<xsl:text>
---

</xsl:text> 
    </xsl:template>
    
    <!-- add whitespace for breaking whitespace -->
    <xsl:template match="tei:pb | tei:cb | tei:lb">
<xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- remove elements from output -->
    <xsl:template match="tei:facsimile"/>
</xsl:stylesheet>
