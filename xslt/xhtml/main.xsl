<?xml version="1.0" encoding="utf-8"?>
<!--
    Copyright (c) 2008, Horst Gutmann <zerok@zerokspot.com>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are 
    met:

        * Redistributions of source code must retain the above copyright 
          notice, this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above copyright 
          notice, this list of conditions and the following disclaimer in the 
          documentation and/or other materials provided with the distribution.
        * Neither the name of the author nor the names of its 
          contributors may be used to endorse or promote products derived from 
          this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
    IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
    THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
    PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    
    ==========================================================================
    
    This is a simple XSLT for transforming an OWL file as generated by 
    Protégé 4.0.x into XHTML. It supports for now just one external
    parameter: "stylesheet". Use this to pass a CSS file or URL
    to the XSLT.
-->
<!DOCTYPE xsl:stylesheet [
    <!ENTITY local-cond "starts-with(@rdf:about, '#') or boolean(@rdf:ID)">
]>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:param name="stylesheet" />
    <xsl:variable name="namespace" select="/rdf:RDF/@xml:base"/>
    <xsl:variable name="title">
        <xsl:value-of select="/rdf:RDF/owl:Ontology/rdfs:label" />
    </xsl:variable>
    <xsl:variable name="datatypeProperties"
        select="/rdf:RDF/owl:DatatypeProperty[&local-cond;]" 
        />
    <xsl:variable name="objectProperties"
        select="/rdf:RDF/owl:ObjectProperty[&local-cond;]"
        />
    <xsl:variable name="classes"
        select="/rdf:RDF/owl:Class[&local-cond;]"
        />
    <!-- === COMMON TEMPLATES =============================================-->
    <xsl:template name="basicInformation">
        <xsl:if test="boolean(./rdfs:label)">
            <dl>
                <dt>Label:</dt>
                <xsl:apply-templates select="./rdfs:label" />
            </dl>
        </xsl:if>
        <xsl:if test="boolean(rdfs:comment)">
            <dl>
                <dt>Description:</dt>
                <xsl:apply-templates 
                    select="./rdfs:comment" />
            </dl>
        </xsl:if>
    </xsl:template>
    <xsl:template name="domainAndRange">
        <xsl:variable name="domain" select="./rdfs:domain/@rdf:resource" />
        <xsl:variable name="range" select="./rdfs:range/@rdf:resource" />
        <xsl:if test="boolean(count($domain))">
            <dl class="domain">
                <dt>Domain:</dt>
                <dd><ul>
                    <xsl:for-each select="$domain">
                        <xsl:call-template name="classRef" />
                    </xsl:for-each>
                </ul></dd>
            </dl>
        </xsl:if>
        <xsl:if test="boolean(count($range))">
            <dl class="range">
                <dt>Range:</dt>
                <dd><ul>
                    <xsl:for-each select="$range">
                        <xsl:call-template name="classRef" />
                    </xsl:for-each>
                </ul></dd>
            </dl>
        </xsl:if>
    </xsl:template>
    <xsl:template name="classRef">
           <xsl:variable name="super" select="." />
           <xsl:choose>
               <xsl:when test="starts-with($super,'#')">
                   <xsl:apply-templates mode="toc"
                       select="$classes[@rdf:about=$super]" />
               </xsl:when>
               <xsl:otherwise>
                   <li><a href="{$super}">
                       <xsl:value-of select="." />
                   </a></li>
               </xsl:otherwise>
           </xsl:choose>
    </xsl:template>
    <!-- === BASE =========================================================-->
    <xsl:template match="/">
        <html>
            <head>
                <title><xsl:value-of select="$title" /></title>
                <style type="text/css">
                    cite {font-style:italic}
                    ul, dd {margin:0; padding:0;}
                    #page {
                        color: #222; width: 750px; margin: auto;}
                    .toc.inline li {
                        float: left; margin: 0 5px 0 0;}
                    .toc.inline li:before{
                        content: ", ";}
                    .toc.inline li:first-child:before{
                        content: none;}
                    .toc.inline ul {
                        list-style: none; overflow: hidden;}
                    a:link {color: #0054C2}
                    h1 {color: #003C8B}
                    dl {
                        overflow:hidden; border-bottom: 1px dotted #AAA;
                        margin: 0; padding: 5px 0}
                    dt {font-weight: bold; float: left; width: 25%}
                    dd {float:right; width: 75%}
                    h2 {
                        background-color: #99C5FF; padding: 3px}
                    h3 {
                        background-color: #D1E4FD; padding: 3px}
                </style>
                <xsl:if test="$stylesheet">
                    <link rel="stylesheet" type="text/css"
                         href="{$stylesheet}" />
                </xsl:if>
                
            </head>
            <body><div id="page">
                <xsl:apply-templates />
            </div></body>
        </html>
    </xsl:template>
    <xsl:template match="rdf:RDF">
        <xsl:apply-templates select="./owl:Ontology" />
        <div id="toc">
            <h2 class="title">Table of Contents:</h2>
            <div id="toc_classes" class="toc inline">
                <h3><xsl:value-of select="count($classes)" /> classes:</h3>
                <ul class="toc">
                    <xsl:apply-templates select="$classes"
                         mode="toc" />
                </ul>
            </div>
            <xsl:if test="boolean(./owl:ObjectProperty)">
                <div id="toc_objectproperties" class="toc inline">
                    <h3><xsl:value-of select="count($objectProperties)" />
                        object properties:</h3>
                    <ul class="toc">
                        <xsl:apply-templates mode="toc"
                             select="$objectProperties" />
                    </ul>
                </div>
            </xsl:if>
            <xsl:if test="boolean(./owl:DatatypeProperty)">
                <div id="toc_datatypeproperties" class="toc inline">
                    <h3><xsl:value-of select="count($datatypeProperties)" />
                        datatype properties:</h3>
                    <ul class="toc">
                        <xsl:apply-templates mode="toc"
                            select="$datatypeProperties" />
                    </ul>
                </div>
            </xsl:if>
        </div>
        <div id="details">
            <h2 class="title">Details</h2>
            <xsl:apply-templates select="./owl:Class" />
            <xsl:apply-templates select="./owl:ObjectProperty" />
            <xsl:apply-templates select="./owl:DatatypeProperty" />
        </div>
        
    </xsl:template>
    <!--=== ONTOLOGY ======================================================-->
    <xsl:template match="owl:Ontology[@rdf:about='']">
        <xsl:if test="./rdfs:label">
            <h1><xsl:value-of select="./rdfs:label" /></h1>
        </xsl:if>
        <xsl:apply-templates select="./dc:creator" />
        <xsl:if test="./dc:contributor">
            <h2>Contributors</h2>
            <ul>
                <xsl:apply-templates select="./dc:contributor" />
            </ul>
        </xsl:if>
        <div class="ontologyinfo">
            <p class="comment"><xsl:value-of select="./rdfs:comment" /></p>
        </div>
    </xsl:template>
    <!--=== CLASS =========================================================-->
    <xsl:template match="owl:Class[starts-with(@rdf:about,'#')]">
        <xsl:variable name="localname" select="substring(./@rdf:about, 2)" />
        <xsl:variable name="range" select="$objectProperties[
            .//rdfs:range[@rdf:resource=concat('#',$localname)]]" />
        <xsl:variable name="domain" select="$objectProperties[
            .//rdfs:domain[@rdf:resource=concat('#',$localname)]]" />
        <xsl:variable name="subclasses" select="$classes[
            rdfs:subClassOf[@rdf:resource=concat('#',$localname)]]" />
        <xsl:variable name="superclasses"
            select="rdfs:subClassOf/@rdf:resource" />
        <div class="class" id="{$localname}">
            <h3 class="qname"><xsl:value-of select="$localname" /></h3>
            <div class="information">
                <xsl:call-template name="basicInformation" />
                <xsl:if test="boolean($subclasses)">
                    <dl>
                        <dt>Subclasses:</dt>
                        <dd><ul>
                            <xsl:apply-templates mode="toc" 
                                select="$subclasses" />
                        </ul></dd>
                    </dl>
                </xsl:if>
                <xsl:if test="boolean($superclasses)">
                    <dl>
                        <dt>Superclasses:</dt>
                        <dd><ul>
                            <xsl:for-each select="$superclasses">
                                <xsl:call-template name="classRef" />
                            </xsl:for-each>
                        </ul></dd>
                    </dl>
                </xsl:if>
                <xsl:if test="boolean($domain)">
                    <dl>
                        <dt>In domain of:</dt>
                        <dd><ul>
                            <xsl:apply-templates mode="toc" 
                                select="$domain" />
                        </ul></dd>
                    </dl>
                </xsl:if>
                <xsl:if test="boolean($range)">
                    <dl>
                        <dt>In range of:</dt>
                        <dd><ul>
                            <xsl:apply-templates mode="toc" select="$range" />
                        </ul></dd>
                    </dl>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
    <!--=== DATATYPE PROPERTY =============================================-->
    <xsl:template match="owl:DatatypeProperty[starts-with(@rdf:about,'#')]">
        <xsl:variable name="localname" select="substring(./@rdf:about, 2)" />
        <div class="datatypeproperty">
            <h3><xsl:value-of select="$localname" /></h3>
            <div class="info">
                <xsl:call-template name="basicInformation" />
                <xsl:call-template name="domainAndRange" />
            </div>
        </div>
    </xsl:template>
    <!--=== OBJECT PROPERTY ===============================================-->
    <xsl:template match="owl:ObjectProperty[starts-with(@rdf:about,'#')]">
        <xsl:variable name="localname" select="substring(./@rdf:about, 2)" />
        <div class="datatypeproperty">
            <h3><xsl:value-of select="$localname" /></h3>
            <div class="info">
                <xsl:call-template name="basicInformation" />
                <xsl:call-template name="domainAndRange" />
            </div>
        </div>
    </xsl:template>
    <!--=== TOC ENTRIES ===================================================-->
    <xsl:template mode="toc"
        match="owl:Class[starts-with(@rdf:about, '#')]">
        <xsl:variable name="localname" select="substring(./@rdf:about, 2)" />
        <li>
            <a href="#{$localname}"><xsl:value-of select="$localname" /></a>
        </li>
    </xsl:template>
    <xsl:template mode="toc"
        match="owl:ObjectProperty[starts-with(@rdf:about, '#')]">
        <xsl:variable name="localname" select="substring(./@rdf:about, 2)" />
        <li>
            <a href="#{$localname}"><xsl:value-of select="$localname" /></a>
        </li>
    </xsl:template>
    <xsl:template mode="toc"
        match="owl:DatatypeProperty[starts-with(@rdf:about, '#')]">
        <xsl:variable name="localname" select="substring(./@rdf:about, 2)" />
        <li>
            <a href="#{$localname}"><xsl:value-of select="$localname" /></a>
        </li>
    </xsl:template>
    <!-- === CREATOR ======================================================-->
    <xsl:template match="dc:creator">
        <xsl:value-of select="text()" />
    </xsl:template>
    

    <xsl:template match="rdfs:label">
        <xsl:choose>
            <xsl:when test="boolean(./@xml:lang)">
                <dd>
                   <xsl:attribute name="xml:lang">
                       <xsl:value-of select="./@xml:lang" />
                   </xsl:attribute>
                   <xsl:value-of select="./text()" />
                </dd>
            </xsl:when>
            <xsl:otherwise>
                <dd><xsl:value-of select="./text()" /></dd>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="rdfs:comment">
        <xsl:choose>
            <xsl:when test="boolean(./@xml:lang)">
                <dd xml:lang="{@xml:lang}">
                    <p class="description">
                        <xsl:value-of select="./text()" /></p>
                </dd>
            </xsl:when>
            <xsl:otherwise>
                <dd><p class="description">
                    <xsl:value-of select="./text()" /></p>
                </dd>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*"></xsl:template>
</xsl:stylesheet>