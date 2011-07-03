<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/">

	<xsl:template match="/">
		<!-- rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		  xmlns:dc="http://purl.org/dc/elements/1.1/">
		  <rdf:Description rdf:about="http://www.w3.org/">
		    <dc:title>World Wide Web Consortium</dc:title> 
		  </rdf:Description>
		</rdf:RDF -->
		
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			<rdf:Description>
				<xsl:attribute name="rdf:about"><xsl:value-of select="//sourceId" /></xsl:attribute>
				<dc:title>
					<xsl:apply-templates
						select="descendant::foxml:property[@NAME='info:fedora/fedora-system:def/model#label']" 
						xmlns:foxml="info:fedora/fedora-system:def/foxml#"/>
				</dc:title>
			</rdf:Description>

		</rdf:RDF>
	</xsl:template>

	<xsl:template match="foxml:property" xmlns:foxml="info:fedora/fedora-system:def/foxml#">
		<xsl:value-of select="@VALUE" />
	</xsl:template>

</xsl:stylesheet>
