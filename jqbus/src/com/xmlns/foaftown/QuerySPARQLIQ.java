package com.xmlns.foaftown;

import org.jivesoftware.smack.packet.IQ;
import org.w3c.dom.Element;


/**
 * Represents an IQ query that carries SPARQL request or response
 * 
 * TODO: review http://www.w3.org/2001/sw/DataAccess/proto-wd/ and impl
 * TODO: breakout <query> from <query-result> ?
 */
public class QuerySPARQLIQ extends IQ
{
	
	public Element element; // from XmlUtils.java		
	public String sparql_escaped;
	public String sparql_plain;
	public String results = "";
	
	
	/** If created with no args, defaults to an "ask everything" sparql query. */
	public QuerySPARQLIQ () 
	{
		super();
		this.setType(IQ.Type.GET);
		sparql_plain = "SELECT ?a ?b ?c WHERE {?a ?b ?c.}";
		sparql_escaped = QuerySPARQLIQ.escapeXML(sparql_plain);
	}
	
	public QuerySPARQLIQ (String sparql) {
		super();
		this.setType(IQ.Type.GET);
		sparql_plain = sparql;		
		sparql_escaped = QuerySPARQLIQ.escapeXML(sparql); // TODO: make a setter function for query 
		System.err.println("QuerySPARQLIQ constructor. plain is: " + sparql_plain +"\n\nescaped is: " + sparql_escaped + "\n\n");
	}
	
	/** 
	 * turn markup into escaped markup
	 * TODO: find a more robust method to escape markup amongst our dozens of XML API jars
	 * @param markup
	 * @return
	 */
	public static String escapeXML(String markup)
	{
	
		markup = markup.replaceAll("&", "&amp;");
		markup = markup.replaceAll("<", "&lt;");
		markup = markup.replaceAll(">", "&gt;");
		return markup;
	
	}
	
	/**
	 * Sets the single child element of this IQ.
	 * @param newElement the child element.
	 */
	public void setElement(Element newElement) 
	{
		// element = newElement;
	}
	
	/*
	 * This is called by Smack to get the SPARQL IQ instance serialized for
	 * shipping over XMPP. When we're a GET, we'll send SPARQL; when we're a
	 * RESULT we'll send SPARQL ResultSet XML. Same for errors.
	 * 
	 */

	public String getChildElementXML()
	{
		return ("\n<query xmlns='http://www.w3.org/2005/09/xmpp-sparql-binding'>\n"
				+ sparql_escaped + "\n</query>\n");		
	}
}
// TODO: move SPARQL XML escaping code here. 
// TODO: move test SPARQL queries out of core library
// this.getType() == IQ.Type.GET