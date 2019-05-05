<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet produces a simple markdown file from TEI XML input for every div in the body of the document</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:include href="Tei2Md-functions.xsl"/>

    <xsl:template match="/">
            <xsl:apply-templates select="descendant::tei:text" mode="mPlainText"/>
    </xsl:template>

    <!-- there should be no MD file for sections -->
    <!-- tei:div[@type = 'section'][not(ancestor::tei:div[@type = 'article'])] |  -->
    <xsl:template
        match=" tei:div[@type = ('article', 'item')][not(ancestor::tei:div[@type = 'bill'])] | 
         tei:div[@type = ('article', 'item')][not(ancestor::tei:div[@type = 'item'][@subtype='bill'])] | 
        tei:div[@type = 'bill'] | 
        tei:div[@type = 'item'][@subtype='bill']" mode="mPlainText">
        <xsl:variable name="vLang" select="$p_lang"/>
        <!-- variables identifying the digital surrogate -->
        <xsl:variable name="vTitleStmt" select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt"/>
        <!-- Need information on edition, date of edition, editors, transcribers etc.  -->
        <!-- variables identifying the original source -->
        <xsl:variable name="vBiblStructSource"
            select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct"/>
        <xsl:variable name="vPublDate"
            select="$vBiblStructSource/tei:monogr/tei:imprint/tei:date[1]"/>
        <xsl:variable name="vPublicationType" select="'Newspaper article'"/>
        <xsl:variable name="vPublicationTitle"
            select="$vBiblStructSource/tei:monogr/tei:title[@level = 'j'][@xml:lang = $vLang][not(@type = 'sub')]"/>
        <xsl:variable name="vArticleTitle">
            <xsl:if test="@type = 'article' and ancestor::tei:div[@type = 'section']">
                <xsl:apply-templates select="ancestor::tei:div[@type = 'section']/tei:head"
                    mode="mPlainText"/>
                <xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="./tei:head" mode="mPlainText"/>
        </xsl:variable>
        <xsl:variable name="vAuthor">
            <xsl:choose>
                        <xsl:when test="tei:byline/descendant::tei:persName">
                            <xsl:copy-of select="tei:byline/descendant::tei:persName"/>
                        </xsl:when>
                        <xsl:when test="descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:author">
                            <xsl:copy-of select="descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:author/descendant::tei:persName"/>
                        </xsl:when>
                        <xsl:when test="descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:title[@level = 'j']">
                            <xsl:copy-of select="descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:title[@level = 'j']"/>
                        </xsl:when>
                    </xsl:choose>
            <!--<xsl:choose>
                <xsl:when test="child::tei:byline/tei:persName/tei:surname">
                    <xsl:value-of select="child::tei:byline/tei:persName/tei:surname"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="child::tei:byline/tei:persName/tei:forename"/>
                </xsl:when>
                <xsl:when test="child::tei:byline/tei:persName">
                    <xsl:value-of select="child::tei:byline/tei:persName"/>
                </xsl:when>
            </xsl:choose>-->
        </xsl:variable>
        <xsl:variable name="vUrl" select="concat($v_url-file, '#', @xml:id)"/>
        <xsl:variable name="v_issue">
            <xsl:choose>
                <!-- check for correct encoding of issue information -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@from = $vBiblStructSource//tei:biblScope[@unit = 'issue']/@to">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@from"/>
                </xsl:when>
                <!-- check for ranges -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@from != $vBiblStructSource//tei:biblScope[@unit = 'issue']/@to">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@from"/>
                    <!-- probably an en-dash is the better option here -->
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@to"/>
                </xsl:when>
                <!-- fallback: erroneous encoding of issue information with @n -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@n">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'issue']/@n"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_volume">
            <xsl:choose>
                <!-- check for correct encoding of volume information -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@from = $vBiblStructSource//tei:biblScope[@unit = 'volume']/@to">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@from"/>
                </xsl:when>
                <!-- check for ranges -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@from != $vBiblStructSource//tei:biblScope[@unit = 'volume']/@to">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@from"/>
                    <!-- probably an en-dash is the better option here -->
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@to"/>
                </xsl:when>
                <!-- fallback: erroneous encoding of volume information with @n -->
                <xsl:when test="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@n">
                    <xsl:value-of select="$vBiblStructSource//tei:biblScope[@unit = 'volume']/@n"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vPages">
            <xsl:value-of select="preceding::tei:pb[@ed = 'print'][1]/@n"/>
            <xsl:if
                test="preceding::tei:pb[@ed = 'print'][1]/@n != descendant::tei:pb[@ed = 'print'][last()]/@n">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="descendant::tei:pb[@ed = 'print'][last()]/@n"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="vPubPlace"
            select="$vBiblStructSource/tei:monogr/tei:imprint/tei:pubPlace/tei:placeName[@xml:lang = $vLang]"/>
        <xsl:variable name="vPublisher" select="$vBiblStructSource/tei:monogr/tei:imprint/tei:publisher/tei:orgName[@xml:lang = $vLang]"/>
        
        <!-- generate the md file -->
<!--        <xsl:result-document href="../jekyll/_posts/{concat($vPublDate/@when,'-',translate($vArticleTitle,' ','-'),'-',$v_id-file,'-',@xml:id)}.md" method="text">-->
        <xsl:variable name="v_file-name">
            <xsl:choose>
                <xsl:when test="$p_output-format = 'md'">
                    <xsl:value-of select="concat('md/',$v_id-file,'-',@xml:id,'.md')"/>
                </xsl:when>
                <xsl:when test="$p_output-format = 'stylo'">
                    <!-- author, file, div -->
                    <xsl:value-of select="'stylo/'"/>
                    <xsl:choose>
                        <xsl:when test="$vAuthor/descendant-or-self::tei:persName/@ref">
                            <xsl:text>oape_</xsl:text>
                            <xsl:value-of select="oape:query-personography($vAuthor/descendant-or-self::tei:persName[1],$v_personography,'oape','')"/>
                        </xsl:when>
                        <xsl:when test="$vAuthor/descendant-or-self::tei:surname">
                            <xsl:value-of select="$vAuthor/descendant-or-self::tei:surname"/>
                        </xsl:when>
                        <xsl:when test="$vAuthor/descendant-or-self::tei:persName">
                            <xsl:value-of select="$vAuthor/descendant-or-self::tei:persName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>NN</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="concat('-',$v_id-file,'-',@xml:id,'.txt')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_include-yaml">
            <xsl:choose>
                <xsl:when test="$p_output-format = 'stylo'">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$p_include-yaml"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:result-document href="../_output/{$v_file-name}" method="text">
            <!-- some metadata on the file itself: YAML. In order to support pandoc conversions etc. the Yaml block should also containe a link to the BibTeX file identifying this article. -->
            <xsl:if test="$v_include-yaml = true()">
            <xsl:text>---</xsl:text><xsl:value-of select="$v_new-line"/>
            <xsl:text>title: "*</xsl:text><xsl:value-of select="normalize-space(replace($vArticleTitle,'#',''))"/><xsl:text>*. </xsl:text><xsl:value-of select="$vPublicationTitle"/><xsl:text> </xsl:text><xsl:value-of select="$v_volume"/><xsl:text>(</xsl:text><xsl:value-of select="$v_issue"/><xsl:text>)</xsl:text><xsl:text>"</xsl:text><xsl:value-of select="$v_new-line"/>
            <xsl:text>author: </xsl:text><xsl:apply-templates select="$vAuthor" mode="mPlainText"/><xsl:value-of select="$v_new-line"/>
            <xsl:text>date: </xsl:text><xsl:value-of select="$vPublDate/@when"/><xsl:value-of select="$v_new-line"/>
            <xsl:text>bibliography: </xsl:text><xsl:value-of select="concat($v_id-file,'-',@xml:id,'.bib')"/><xsl:value-of select="$v_new-line"/>
            <xsl:text>---</xsl:text><xsl:value-of select="$v_new-line"/><xsl:value-of select="$v_new-line"/>
            </xsl:if>
            <!-- text body -->
            <xsl:apply-templates mode="mPlainText"/>
            <!-- notes -->
            <xsl:choose>
                <xsl:when test="$p_output-format = 'stylo'"/>
                <xsl:otherwise>
                    <xsl:value-of select="$v_new-line"/><xsl:value-of select="$v_new-line"/>
                    <xsl:call-template name="t_notes"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:result-document>
    </xsl:template>


</xsl:stylesheet>
