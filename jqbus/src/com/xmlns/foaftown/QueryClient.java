/*
 * This file is in the Public Domain
 */
package com.xmlns.foaftown;

import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.Packet;
import org.jivesoftware.smack.ChatManager; 
import org.jivesoftware.smack.Chat; 
import org.jivesoftware.smack.MessageListener; 
import org.jivesoftware.smack.packet.Message; 

/**
 * @author Dan Brickley
 * @author ldodds
 */
public class QueryClient implements PacketListener
{
    private XMPPConnection _connection;
	private MessageListener _handler;	// not sure about adding this - danbri
		
    /**
     * Start client with a pre configured and logged in connection
     */
    public QueryClient(XMPPConnection connection)
    {
        _connection = connection;
        _connection.addPacketListener(
                this, 
                new SPARQLResultPacketExtensionFilter());
    }
    
    public QueryClient(String server, 
            		   String user, 
            		   String password,
            		   String resource)
	   	throws XMPPException
    {
        _connection = new XMPPConnection(server);
		
		System.out.println("Trying to connect as client role.");
		try {
			_connection.connect();
		} catch (org.jivesoftware.smack.XMPPException e) {
		  System.err.println("Failed to connect");
		}
				
        _connection.login(user, password, resource);
        _connection.addPacketListener(
                this, 
                new SPARQLResultPacketExtensionFilter());
	}
		
	public void processPacket(Packet packet)
	{
		System.err.println("Client got a packet of interest: "
				+ packet.toXML());
		try
		{
			// java5 smack version
			// http://www.igniterealtime.org/builds/smack/docs/latest/documentation/messaging.html
			ChatManager chatmanager = _connection.getChatManager();
			Chat newChat = chatmanager.createChat(packet.getFrom(), new MessageListener() {
			    public void processMessage(Chat chat, Message message) {

						try {
							chat.sendMessage("client processMessage method called; replying to prove it!");
						} catch (org.jivesoftware.smack.XMPPException e) {
							System.err.println("Problem replying via processMessage listener.");
						}
						
				        System.out.println("Received message: " + message); // but when is this called? never seems to be...
			    }
			}); // "The listener is notified any time a new message arrives from the other user in the chat." (only Messages, not IQ?)
			newChat.sendMessage("query results received with thanks!"); // this could be in the MessageListener ?
//			Chat newChat2 = chatmanager.createChat(packet.getFrom(),_handler); // do what we meant to do

		}
		catch (Exception e)
		{
			System.err.println("Failed to reply via XMPP");
		}
		
	    
	}
	
	// send a query and register a handler
	public void sendQuery(String jid, String query, MessageListener handler) 
	{
		this._handler = handler;
		sendQuery(jid, query);
	}
	
	public void sendQuery(String jid, String query)
	{
		QuerySPARQLIQ spRequest = new QuerySPARQLIQ(query);
		spRequest.setType(IQ.Type.GET);
		spRequest.setTo(jid);
		_connection.sendPacket(spRequest);	    
	}
}
