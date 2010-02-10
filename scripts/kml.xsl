<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>

<xsl:output method='xml' encoding='utf-8' indent='yes'/>

<xsl:template match="ghcn">
	<kml>
	<Document>
		<name>
			<xsl:text>GHCN Stations</xsl:text> 
		</name>
		<open>
			<xsl:text>1</xsl:text>
		</open>
		<description>
			<xsl:text>GHCN Stations for Endless Summer GmbH</xsl:text> 
		</description>
			<xsl:apply-templates select="GHCN-Data-Schema-Station"/>
	</Document>
</kml>
</xsl:template>

<xsl:template match="GHCN-Data-Schema-Station">
	<Placemark>
		<description>
			<xsl:text>Station id: </xsl:text><xsl:value-of select="wmo_number"/><xsl:value-of select="modifier"/><br/>
			<table style="border: 1px solid black; text-align: right; border-collapse: collapse;">
				<tr>
					<td style="border: 1px solid black;"></td>
					<td style="border: 1px solid black;"><xsl:text>january</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>february</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>march</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>april</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>may</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>june</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>july</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>august</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>september</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>october</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>november</xsl:text></td>
					<td style="border: 1px solid black;"><xsl:text>december</xsl:text></td>
				</tr>
				<xsl:apply-templates select="GHCN-Data-Schema-DataSet" />
			</table>
		</description>
		<name>
			<xsl:value-of select="name"/>
		</name>
		<Point>
			<altitudeMode>
				<xsl:text>clampToGround</xsl:text>
			</altitudeMode>
			<coordinates>
				<xsl:value-of select="longitude"/><xsl:text>,</xsl:text>,<xsl:value-of select="latitude"/>
			</coordinates>
		</Point>
	</Placemark>
</xsl:template>

<xsl:template match="GHCN-Data-Schema-DataSet">
		<tr>
			<td style="border: 1px solid black; text-align: left;">
				<xsl:value-of select="@type"/>
			</td>
			<xsl:for-each select="january|february|march|april|may|june|july|august|september|august|september|october|november|december">
				<xsl:call-template name="value"/>
			</xsl:for-each>
		</tr>
</xsl:template>


<xsl:template name="value">
			<td style="border: 1px solid black;">
				<xsl:choose>
					<xsl:when test="string(.)">
						<xsl:value-of select='format-number(., "###.##")'/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>-</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</td>
</xsl:template>

</xsl:stylesheet>