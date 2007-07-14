package com.xmlns.foaftown;

import java.io.*;
import org.jivesoftware.smack.packet.IQ;

import org.w3c.dom.Element; // W3C DOM
import org.w3c.dom.Document; 

import org.apache.xerces.dom.DocumentImpl; // Xerces classes.
import org.apache.xml.serialize.*;

import com.hp.hpl.jena.query.* ;

/**
 * Represents an IQ query that carries SPARQL request or response
 * TODO: review http://www.w3.org/2001/sw/DataAccess/proto-wd/ and impl
 */
public class ResultsSPARQLIQ extends IQ
{
	
	private Element element; // from XmlUtils.java
		
	public String sparql_escaped;

	public String sparql_plain;

	public String results = "";
	
	public String rawxml;

	private ResultSet resultset;
	
	private byte[] rawbytes;
	
	
	public ResultsSPARQLIQ () {
		super();
		this.setType(IQ.Type.RESULT);
	}
	
	
	/**
	 * Sets the single child element of this IQ.
	 * @param newElement the child element.
	 */
	public void setElement(Element newElement) {
		element = newElement;
	}
	
	/* make a resultset from the bytes (afresh each time; or is it rewindable?) */
	public ResultSet resultset() {
		ResultSet rs = ResultSetFactory.fromXML( new ByteArrayInputStream(rawbytes));
		resultset = rs; 
		return rs;
	}
	
	/*
	 * This is called by Smack to get the SPARQL IQ instance serialized for
	 * shipping over XMPP and for populating the IQ's state. 
	 */

	public String getChildElementXML()
	{
		// System.err.println("ResultsSparqlIQ.getChildElement() on an IQ " + this.getType());

		if (this.getType() == IQ.Type.RESULT)
		{
			String txt = "";				
			String msg = "";
			Document xmldoc;
			if (element != null) {
				txt = element.toString() ;
				msg = "content generated via DOM conversion.";
				xmldoc = new DocumentImpl();
				OutputFormat of = new OutputFormat("XML","UTF-8",true);
				try 
				{	
				 // FileOutputStream fos = new FileOutputStream(filename);
				 ByteArrayOutputStream out = new ByteArrayOutputStream();
				 of.setIndent(1);
				 of.setIndenting(true);
				 XMLSerializer serializer = new XMLSerializer(out, of);
				 serializer.asDOMSerializer();
				 Element rxml = (Element)element.getElementsByTagName("sparql").item(0);
				 serializer.serialize(rxml);
				 rawbytes = out.toByteArray();
				 ByteArrayInputStream bs = new ByteArrayInputStream(rawbytes);
				 ResultSet rs = ResultSetFactory.fromXML( bs );
				 
				 resultset = rs; // rewindable?
				 
				 // System.err.println("Query client got a resultset.");
				 ResultSetFormatter rsf = new ResultSetFormatter();
				 // rsf.outputAsText(System.err);
				 txt = rsf.asXMLString( rs ).replaceAll(
						 "<\\?xml version=\"1.0\"\\?>", ""
						 ); // TODO: move prolog trimmer to utils
				 //System.err.println("Parsed and reserialized: \n"+txt+"\n\n");
				 rawxml = txt;
				 
				 // TODO: store query resultset state in rewindable form in ResultsSPARQLIQ
				} catch (Exception e) {
					System.err.println("Error handling resultset response - "+e);
				}			
			} else {
				txt = results;
				msg = "content supplied programmatically";
			}
			
			// System.err.println("Sending this back inside query-result: \n\n"+txt+"\n\n");
			return ("\n<query-result xmlns='"+ FoafJabberNode.XMPP_SPARQL_BINDING_URI
					+ "'>\n"					
					+ "<meta comments='"+msg+"'/>"+txt+"\n</query-result>\n");
		}
		return "";
	}
	// TODO: error check for non-result IQ packets that got sent our way?
}

// Other ways to get the output/input plumbing done:
// http://ostermiller.org/convert_java_outputstream_inputstream.html