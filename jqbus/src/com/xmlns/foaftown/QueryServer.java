/*
 * This file is in the Public Domain
 */
package com.xmlns.foaftown;

import java.io.InputStream;

import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.packet.IQ;
import org.jivesoftware.smack.packet.Packet;
import org.jivesoftware.smack.ChatManager; 
import org.jivesoftware.smack.Chat; 
import org.jivesoftware.smack.MessageListener; 
import org.jivesoftware.smack.packet.Message; 

import com.hp.hpl.jena.query.*;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.util.FileManager;

/**
 * @author Dan Brickley
 * @author ldodds
 */
public class QueryServer implements PacketListener
{
    private XMPPConnection _connection;
    private Model _model;    
    
    /**
     * Create QueryServer with already existing connection
     * 
     * @param connection
     */
    public QueryServer(XMPPConnection connection)
    {
        _connection = connection;
        _connection.addPacketListener(
                this,
                new SPARQLQueryPacketExtensionFilter());
        
        _model = ModelFactory.createDefaultModel();

		
	}

    /**
     * Create a QueryServer. Will automatically connect and 
     * login to a server using provided parameters
     * 
     * @param server
     * @param user
     * @param password
     * @param resource
     * @throws XMPPException
     */
    public QueryServer(String server, 
            		   String user, 
            		   String password,
            		   String resource)
    	throws XMPPException
    {
        _connection = new XMPPConnection(server);
		
		
		System.out.println("Trying to connect as server role.");
		try {
			_connection.connect();
		} catch (org.jivesoftware.smack.XMPPException e) {
		  System.err.println("Failed to connect");
		}
		// http://www.igniterealtime.org/forum/message.jspa?messageID=148811
		// todo - if this works, fix QueryClient too


        _connection.login(user, password, resource);
        _connection.addPacketListener(
                this,
                new SPARQLQueryPacketExtensionFilter());        
        _model = ModelFactory.createDefaultModel();        
    }
    
    public Model getModel()
    {
        return _model;
    }
    
    public void addFile(String file)
    {
	
	try {
			// use the FileManager to find the input file
			InputStream in = FileManager.get().open( file );
			if (in == null) 
			{
				throw new IllegalArgumentException(		                                 
						"File: " + file + " not found");
			}				
			try 
			{ 
				_model.read(in, "");
			} catch (Exception e) 
			{
				System.err.println("Server can't open RDF file: "+ file );
				e.printStackTrace();
			}
		} catch (Exception e) {
			System.err.println("Quietly ignoring trouble loading RDF file: "+file);
		}

    }

	public void processPacket(Packet packet)
	{
		QuerySPARQLIQ iqp = (QuerySPARQLIQ) packet;
		String sparql_txt = iqp.sparql_plain;
		System.err.println("Incoming IQ packet has query: " + sparql_txt);
		
		Query q = QueryFactory.create(sparql_txt);
		QueryExecution qexec = QueryExecutionFactory.create(q, _model);
		ResultSet results = qexec.execSelect();
		// StringWriter sw = new StringWriter();
		ResultSetFormatter rfo = new ResultSetFormatter();
		//String reply = "Query execute. I might send the results someday..."
		//		+ " would be to " + packet.getPacketID();
		ResultsSPARQLIQ spResults = new ResultsSPARQLIQ();
		String rawxml = rfo.asXMLString(results); 
		spResults.results = rawxml.replaceAll(
				"<\\?xml version=\"1.0\"\\?>", "");
		rfo.outputAsXML(System.err, results); // can we output twice?
		spResults.setType(IQ.Type.RESULT);
		Packet them = (Packet) spResults;
		them.setPacketID(packet.getPacketID()); // indicate we're replying
		spResults.setTo(packet.getFrom()); // ...and return to sender
		try
		{
			_connection.sendPacket(spResults);

			// java5 smack version
			// http://www.igniterealtime.org/builds/smack/docs/latest/documentation/messaging.html
			ChatManager chatmanager = _connection.getChatManager();
			Chat newChat = chatmanager.createChat(packet.getFrom(), new MessageListener() {
			    public void processMessage(Chat chat, Message message) {
				        System.out.println("Received message: " + message);
			    }
			});

			newChat.sendMessage("IQ reply also sent");

//old:			_connection.createChat(packet.getFrom()).sendMessage("IQ reply also sent");


		}
		catch (Exception e)
		{
			System.err.println("Failed to reply via XMPP");
		} // how can the anon class "throws XMPPException" instead?
	    
	}
}
