package com.xmlns.foaftown;

import com.xmlns.foaftown.xml.*;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.provider.IQProvider;
import org.xmlpull.v1.XmlPullParser;
import org.w3c.dom.Element;
//import org.w3c.dom.DOMException;
//import org.w3c.dom.Document;
//import org.w3c.dom.Text;
//import org.xmlpull.v1.XmlPullParser;
//import org.xmlpull.v1.XmlPullParserException;
//import org.xmlpull.v1.XmlPullParserFactory;

import org.w3c.dom.Element; // W3C DOM
import org.w3c.dom.Document; 

/**
 * This class concerns itself with parsing SPARQL Results in IQ data. 
 * The parseIQ method populates an IQ based on markup from the XMPP stream. 
 * 
 * IQ spec:
 * http://www.xmpp.org/specs/rfc3920.html#stanzas-semantics-iq
 * 
 * TODO: BUG!! problem: we fell back to <iq><query> so we're using the wrong provider
 * 
 * We're using (.xml.* package is from there) this approach:
 * http://ex-337.net/gradient/docs/design/iq-providers.html
 * http://ex-337.net/gradient-javadoc/net/ex_337/gradient/packet/DOMIQProvider.html
 * http://ex-337.net/downloads/gradient-src.1.0.0.zip
 * Todo: capture incoming xml resultset markup as a DOM
 */

public class SPARQLResultsProvider implements IQProvider
{
	public SPARQLResultsProvider()
	{
		//System.err.println("SPARQLQueryProvider() constructor'd...");
	}

	public IQ parseIQ(org.xmlpull.v1.XmlPullParser xpp)
	{
		
		//System.err.println("SPARQLResultsProvider parseIQ called. Saving to DOM.");
		ResultsSPARQLIQ results = new ResultsSPARQLIQ();	
		try 
		{
			Element iqElement = XMLUtils.PULL2DOM.parse(xpp);
			results.setElement(iqElement); // stash XML state		
			
		} catch (Exception e) {
			System.err.println("Error saving XML stream as DOM :"+e.toString());
		}
        String resultset = "SORRY, NO RESULTS EXTRACTED YET!";
		results.results = resultset; 
		return results;
	}
}