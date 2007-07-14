package com.xmlns.foaftown;

import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.provider.IQProvider;
import org.xmlpull.v1.XmlPullParser;

//import com.xmlns.foaftown.xml.*; // XmlUtils + minimal dependencies (remove those?)

//import org.w3c.dom.DOMException;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.Text;
//import org.xmlpull.v1.XmlPullParser;
//import org.xmlpull.v1.XmlPullParserException;
//import org.xmlpull.v1.XmlPullParserFactory;

/**
 * This class concerns itself with parsingSPARQL IQ data. The parseIQ method
 * populates an IQ based on markup from the XMPP stream (we look at the elements
 * to figure out if the stream carries a query versus its results... not sure
 * how else to determine). This is closely bound up with the
 * getChildElementXML() of QuerySPARQLIQ which does the opposite; it inspects its
 * state (which SPARQLQueryProvider populates from markup) and reconstructs
 * appropriately similar XML. Note that a receiving app won't get the raw
 * streamed XML, but only access to the parts that survive the parseIQ parser!
 * So make sure these two classes are in sync.
 * 
 * See also:
 * http://ex-337.net/gradient/docs/design/iq-providers.html
 * http://ex-337.net/gradient-javadoc/net/ex_337/gradient/packet/DOMIQProvider.html
 * ...for an approach to 'pass through' provider. Could adapt this to grab
 * the output into a form re-parsable by ARP, for XML SPARQL Results?
 * http://ex-337.net/downloads/gradient-src.1.0.0.zip
 * Todo: capture incoming xml resultset markup as a DOM
 * OK. A plan. We'll use public domain XMLUtils (in the cvs tree)
 * 
 */

public class SPARQLQueryProvider implements IQProvider
{
	public SPARQLQueryProvider()
	{
		System.err.println("SPARQLQueryProvider() constructor'd...");
	}

	public IQ parseIQ(org.xmlpull.v1.XmlPullParser xpp)
	{

		// OK our job is to fabricate an IQ object from the incoming XML
		// NOTHING ELSE. Then Listeners do the rest later...

		System.out.println("SPARQLQueryProvider parseIQ called - Parsing out some sparql...");
		QuerySPARQLIQ query = new QuerySPARQLIQ();

		boolean in_query = false; // XML state

		boolean bored_yet = false; // eg. we wander off after </query>;
									// infinite stream...
		String sparql_txt = "";
		
		String resultset = "";

		try
		{
			// see http://www.xmlpull.org/v1/doc/api/org/xmlpull/v1/XmlPullParser.html
			// http://www.xmlpull.org/v1/download/unpacked/src/java/samples/MyXmlPullApp.java
			int eventType = xpp.getEventType();

			while (eventType != XmlPullParser.END_DOCUMENT && !bored_yet)
			{
				if (eventType == XmlPullParser.START_DOCUMENT)
				{
					// System.err.println("Start document");
				}
				else if (eventType == XmlPullParser.END_DOCUMENT)
				{
					// System.err.println("End document");
				}
				else if (eventType == XmlPullParser.START_TAG)
				{
					// System.err.println("Start tag "+xpp.getName());
					if (xpp.getName().equals("query"))
					{
						in_query = true;
						// System.err.println("in_query = true");
					}
				}
				else if (eventType == XmlPullParser.END_TAG)
				{
					// System.err.println("End tag "+xpp.getName());
					if (xpp.getName().equals("query"))
					{
						in_query = false;
						// System.err.println("in_query = false");
						bored_yet = true;
					}
				}
				else if (eventType == XmlPullParser.TEXT)
				{
					// System.err.println("Text "+xpp.getText());
					if (in_query)
					{
						String txt = xpp.getText();
						sparql_txt += txt;
						// System.err.println("appending query text: "+txt);
					}
				}
				eventType = xpp.next();
			}
		}
		catch (Exception e)
		{
			System.err
					.println("TODO: use a real error logger like Apache's. Pull parser barfed.");
		}
		System.err.println("Extracted query: " + sparql_txt);


		// TODO: finish moving entity escaping code into getChildElementXML() - static or instance method?
		query.sparql_plain = sparql_txt;
		sparql_txt = sparql_txt.replaceAll("&", "&amp;");
		sparql_txt = sparql_txt.replaceAll("<", "&lt;");
		sparql_txt = sparql_txt.replaceAll(">", "&gt;");
		// System.err.println("Escaped query: "+sparql_txt);
		query.sparql_escaped = sparql_txt;

		resultset = sparql_txt; // So wrong, just testing our string results
								// show here
		query.results = resultset; // TODO: break out parsing query from
									// results.

		return query;
	}
}
