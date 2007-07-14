package com.xmlns.foaftown;

import org.jivesoftware.smack.filter.PacketExtensionFilter;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.Packet;

/**
 * A PacketExtensionFilter that only accepts QuerySPARQLIQ RESULT Packets 
 */

public class SPARQLResultPacketExtensionFilter extends PacketExtensionFilter
{

	public boolean accept(Packet incoming)
	{
		if (incoming instanceof ResultsSPARQLIQ)
		{
			//System.err.println("SPARQLResultPacketExtensionFilter got QuerySPARQLIQ.");
			if (((IQ) incoming).getType() == IQ.Type.RESULT)
			{
				//System.err.println("...that is a RESULT");
				return true;
			}
			else
			{
				return false;
			}
		}
		return false;
	}

	public SPARQLResultPacketExtensionFilter(String a, String b)
	{
		super(a, b); 
		// System.err.println("Constructed (,) SPARQLResultPacketExtensionFilter");
	}

	public SPARQLResultPacketExtensionFilter()
	{
		super("query", FoafJabberNode.XMPP_SPARQL_BINDING_URI);
		//System.err
		//		.println("Constructed () a SPARQLResultPacketExtensionFilter");
	}
}
