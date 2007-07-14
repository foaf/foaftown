package com.xmlns.foaftown;

import org.jivesoftware.smack.filter.PacketExtensionFilter;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.Packet;

/**
 * A PacketExtensionFilter that only accepts QuerySPARQLIQ GET Packets see
 * http://www.jivesoftware.org/builds/smack/docs/latest/javadoc/org/jivesoftware/smack/filter/PacketExtensionFilter.html
 * OK how is this working? There's a version of the constructor that wants this:
 * PacketExtensionFilter(String elementName, String namespace) Creates a new
 * packet extension filter. ...yet the () seems to work for finding IQ GET
 * packets, while our RESULTS are bouncing back off the client, 503 service
 * unavailable. Should we set these up with namespace + element name?
 */
class SPARQLQueryPacketExtensionFilter extends PacketExtensionFilter
{

	public boolean accept(Packet incoming)
	{
		if (incoming instanceof QuerySPARQLIQ)
		{
			// System.err.println("SPARQLQueryPacketExtensionFilter got QuerySPARQLIQ.");
			if (((IQ) incoming).getType() == IQ.Type.GET)
			{
				System.err.println("...that is a GET");
				return true;
			}
			else
			{
				return false;
			}
		}
		return false;
	}

	public SPARQLQueryPacketExtensionFilter(String a, String b)
	{
		super(a, b); 
	}

	public SPARQLQueryPacketExtensionFilter()
	{
		super("query", FoafJabberNode.XMPP_SPARQL_BINDING_URI);
	}
}