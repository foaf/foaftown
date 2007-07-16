	package com.xmlns.foaftown;

import org.jivesoftware.smack.PacketListener;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.filter.PacketFilter;
import org.jivesoftware.smack.packet.Packet;
import org.jivesoftware.smack.provider.IQProvider;
import org.jivesoftware.smack.provider.ProviderManager;
import org.jivesoftware.smack.util.StringUtils;
import org.jivesoftware.smack.MessageListener; 
import org.jivesoftware.smack.Chat; 
import org.jivesoftware.smack.Roster; 
import org.jivesoftware.smack.packet.Message; 

import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.ResultSetFormatter;

import java.util.Iterator;

/**
 * @author Dan Brickley
 */

/**
 * An ad-hoc class that can set up client and servers for RDF query over XMPP
 */
class FoafJabberNode
{

	public final static String XMPP_SPARQL_BINDING_URI = "http://www.w3.org/2005/09/xmpp-sparql-binding";


	// From -D commandline, passed through via sysproperty in build.xml:


	public String role;

	public String pwd;

	public String my_jid;

	public String other_jid;
	
	
	// derrived from commandline
	
	public String client_jid;

	public String client_userid;

	public String client_host;

	public String client_res;


	public String server_jid;

	public String server_userid = "n/a";

	public String server_host = "n/a";

	public String server_res;

	
	
	public static void main(String args[]) throws XMPPException, Exception
	{
		java.util.Enumeration keys = System.getProperties().keys();
		// while( keys.hasMoreElements() ) { System.err.println(keys.nextElement() ); }
	
		XMPPConnection.DEBUG_ENABLED = true;
		FoafJabberNode hj = new FoafJabberNode();
	
	
		if (System.getProperty( "foaftown.role" ) != null ) {
			hj.role = System.getProperty( "foaftown.role" );
			System.err.println("Set .role to "+hj.role);
	    } else { 
			throw new Exception("No role specified in System preferences");
		}

		if (System.getProperty( "foaftown.pwd" ) != null ) {
			hj.pwd = System.getProperty( "foaftown.pwd" );
			// Nah :) System.err.println("Set .pwd to "+hj.pwd);
	    }

		if (System.getProperty( "foaftown.my_jid" ) != null ) {
			hj.my_jid = System.getProperty( "foaftown.my_jid" );
			System.err.println("Set .my_jid to "+hj.my_jid);
	    } else {
			throw new Exception("No my_jid specified in System preferences");
		}

		// only needed if we are a client
		if (System.getProperty( "foaftown.other_jid" ) != null ) {
			hj.other_jid = System.getProperty( "foaftown.other_jid" );
			System.err.println("Set .other_jid to "+hj.other_jid);
			if (hj.role.equals("server") ) { System.err.println("Ignoring other_jid as in server role"); }
	    } else {
			System.err.println("Warning, no other_jid specified in System preferences");
		}

		hj.startup();
	}


	public FoafJabberNode()
	{
		IQProvider myqueryprov = new SPARQLQueryProvider();
		IQProvider myresultsprov = new SPARQLResultsProvider();
		ProviderManager.getInstance().addIQProvider("query", XMPP_SPARQL_BINDING_URI, myqueryprov);
		ProviderManager.getInstance().addIQProvider("query-result", XMPP_SPARQL_BINDING_URI, myresultsprov);
	}

	
	public void startup() throws XMPPException, Exception
	{

		System.err.println("Node startup. Reading everything from commandline.");

		if (my_jid == null) { throw new Exception ("Who am I? no -Dfoaftown.my_jid specified..."); }

		if (my_jid != null && role.equals("client")) { 
			client_jid = my_jid; 
			server_jid = other_jid; 
			System.err.println("As a client, Set client_jid to be my_jid, ie. "+my_jid);
		};
		if (my_jid != null && role.equals("server")) { server_jid = my_jid; System.err.println("As a server, Set server_jid to be my_jid, ie. "+my_jid);}; 			
		client_userid = StringUtils.parseName(client_jid);			
		client_host = StringUtils.parseServer(client_jid); 
		server_userid = StringUtils.parseName(server_jid); 
		server_host = StringUtils.parseServer(server_jid);
		System.err.println("Server_jid: "+server_jid);
		System.err.println("client_userid: "+client_userid+" client_host: "+client_host+" server_userid: "+server_userid+ " server_host: "+ server_host+"\n\n");
	
	    if (server_host.equals("gmail.com") ) { server_host = "talk.google.com"; System.err.println("Specialcasing gmail: "+server_host); }
		
		if (role.equals("client"))
		{
			sparql_client();
		}
		else if (role.equals("server"))
		{
			sparql_server();
		}
		else if (role.equals("rdfclient"))
		{
			String q = "PREFIX foaf: <http://xmlns.com/foaf/0.1/> "
				+ " SELECT * "
				+ " WHERE { ?s ?p ?o } ";
			
			System.err.println("Basic rdfclient test. query is: \n" + q + "\n");

			final XMPPConnection con = new XMPPConnection(client_host);
			con.connect();
			con.login(client_userid, pwd, "sparqlclient");		
			QuerySPARQLIQ spRequest = new QuerySPARQLIQ(q); 
			spRequest.setTo(server_jid + "/sparqlserver"); 
			con.sendPacket(spRequest);
			PacketFilter filter = new SPARQLResultPacketExtensionFilter();
			PacketListener myListener = new PacketListener() {
				public void processPacket(Packet results) {
					ResultSet rs = ((ResultsSPARQLIQ)results).resultset();
					ResultSetFormatter rfo = new ResultSetFormatter();
					rfo.out( System.err, rs );
				}
			};
			con.addPacketListener(myListener, filter); 			
		}
		// TODO: [research] potential GUI? - http://www.ldodds.com/projects/twinkle/
		// TODO: how to avoid these? - java.lang.OutOfMemoryError 
		else if (role.equals("findmusic"))
		{
			String q = "PREFIX dc: <http://purl.org/dc/elements/1.1/> "
				+ "PREFIX mm: <http://musicbrainz.org/mm/mm-2.1#> "
				+ " SELECT ?title ?creator "
				+ " WHERE { [ dc:creator \"New Order\"; "
				+ " dc:title ?title; ] } ";
			
			System.err.println("Music test:\n" + q + "\n");

			final XMPPConnection con = new XMPPConnection(client_host);
			con.login(client_userid, pwd, "findmusic");		
			QuerySPARQLIQ spRequest = new QuerySPARQLIQ(q); 
			spRequest.setTo(server_jid + "/sparqlserver"); 
			con.sendPacket(spRequest);
			PacketFilter filter = new SPARQLResultPacketExtensionFilter();
			PacketListener myListener = new PacketListener() {
				public void processPacket(Packet results) {
					ResultSet rs = ((ResultsSPARQLIQ)results).resultset();
					ResultSetFormatter rfo = new ResultSetFormatter();
					rfo.out( System.err, rs );
				}
			};
			con.addPacketListener(myListener, filter); 			
		}
		else
		{
			throw new Exception("Unknown role");
		}
	}

	
	public void sparql_server() throws XMPPException
	{
		System.err.println("Attaching RDF to Jabber at server="+server_host+" user= "+server_userid);
		
	    QueryServer server = new QueryServer(server_host,
	            server_userid, pwd, "sparqlserver");
	    //server.addFile("c:\\projects\\ldodds-knows.rdf");
	    server.getModel().read("http://danbri.org/foaf.rdf");
	    // server.addFile("/home/danbri/semlife/_music.rdf");
		server.addFile("/Users/danbri/foafns/foaf.rdf"); // priv copy of ns spec
	}

	public void sparql_client() throws XMPPException
	{
	    QueryClient client = new QueryClient(
	            client_host, client_userid, pwd, "sparqlclient");
	    
	
		String q =  "SELECT ?s ?p ?o WHERE {?s ?p ?o.}";
		// q = "PREFIX foaf <http://xmlns.com/foaf/0.1/> SELECT ?name ?url WHERE { [ a foaf:Person; foaf:name ?name;  foaf:homepage ?url ; ] } ";

		q =  "SELECT DISTINCT ?p ?o WHERE {?s ?p ?o.}"; // ok
		q =  "SELECT DISTINCT ?p ?o WHERE {?s <http://xmlns.com/foaf/0.1/name> ?o.}"; // ok
		q =  "SELECT DISTINCT ?p ?o WHERE {?s ?p ?o.}"; // ok
		q =  "PREFIX foaf: <http://xmlns.com/foaf/0.1/> SELECT DISTINCT ?o WHERE {?s foaf:name ?o.}"; // not ok
		
		
		q =  "SELECT DISTINCT ?x ?y WHERE {?x <http://www.w3.org/2004/02/skos/core#broader> ?y .}"; // skos

		/*		
		Roster r = con.getRoster();
		System.err.println("Connection roster of client " + client_jid
				+ " is: " + r.toString());
		for (Iterator i = r.getEntries(); (Iterator)i.hasNext();)
		{
			System.err.println("Roster item: " + i.next());
		}

		Iterator them = r.getPresences(server_jid);
		if (them == null)
		{
			System.err.println("Server " + server_jid
					+ " has no presences visible to " + client_jid);
		}
		else
		{
			System.err.println("Presences: " + them.toString());
		}
		*/
		
	    client.sendQuery(server_jid+"/sparqlserver", q);
		
		
		
		/* MessageListener ml = new MessageListener() {
			    public void processMessage(Chat chat, Message message) {
				        System.out.println("client ml called back with message: " + message);
						try {
							chat.sendMessage("OK Got the SPARQL results!"); 
						} catch (org.jivesoftware.smack.XMPPException e) {
							System.err.println("org.jivesoftware.smack.XMPPException while sending a sparql client thankyou. Ignoring for now.");
						}
						// ...now how do I process them, eg. into a ResultSetFormatter or ResultsViewer 
			    }
			};
		*/
		// client.sendQuery(server_jid+"/sparqlserver", "SELECT ?s ?p ?o WHERE {?s ?p ?o.}", ml);

		// trying leigh's code:
		//ResultViewer viewer = new ResultsViewer("Query Results, Packet=" + package.getPacketID());
		//viewer.show();
		//viewer.display(results);
 		
		// Have a look around to see who is online
		// (eventually we'll select target jids here)
		//

		
	}
}

/*
 * -----------------------------------------------------------------------------------
 * Pre-Wiki notes
 * -----------------------------------------------------------------------------------
 * TODO: [research] does server_jid authorize client_jid to see its presence? 
 * TODO: [research] find out if roster entries are foo@server/res or just foo@server or either
 * We can see foaf's presence from foaf2's account and vice-versa, in GUI client apps but
 * still get a null list here, even when foaf2 is logged in via Gossip :(
 * http://www.jivesoftware.org/builds/smack/docs/latest/javadoc/org/jivesoftware/smack/Roster.html#getPresences(java.lang.String)
 * compare with Time IQ Get
 * //http://www.jivesoftware.org/builds/smack/docs/latest/javadoc/org/jivesoftware/smackx/packet/Time.html
 * Presence p = (Presence)them.next(); System.err.println("Got a presence:
 * "+p.toString() ); // this all isn't quite right. need to break out client and //
 * server roles.... // Create a packet collector to listen for a response.
 * PacketCollector collector = con.createPacketCollector( new
 * PacketIDFilter(sparqlRequest.getPacketID())); con.sendPacket(sparqlRequest); //
 * Wait up to 5 seconds for a result. IQ result =
 * (IQ)collector.nextResult(5000); if (result != null && result.getType() ==
 * IQ.Type.RESULT) { System.out.println("Got result: "+result.toString());
 * QuerySPARQLIQ sparqlResult = (QuerySPARQLIQ)result; // Do something with result...
 * System.out.println("Got results: "+sparqlResult); } On parsing XMPP-carried
 * resultset: look at XMLInputStAX which parses result sets using StAX and is
 * pull-centric. Does the pull-to-iterator conversion. (AndyS). ARQ XML result
 * set reader On presence:
 * http://www.jivesoftware.org/forums/thread.jspa?threadID=15730&tstart=0 - For
 * security reasons, XMPP servers will not expose a user's presence to another
 * user unless the user has previously authorized the other user to see his
 * presence. ---how? Just being on Roster? Seems so... You want to use
 * Roster#getPresences(userID) then iterate through that list looking for the
 * resource with the highest priority. 
 * public Presence getPresence(String user)
 * You should be able to get a resource via:
 * StringUtils.parseResource(Presence#getFrom()) You can also look in the smack
 * debugger to see which resource you are using but if you are just using
 * conn#login(username, password) your resource will be "Smack". If you would
 * like to use your own resource try, conn#login(username, password, resource)
 * instead. 
 * 
 * Jabber/XMPP Background: 
 * Jabber Search JEP: http://www.jabber.org/jeps/jep-0055.html 
 * Field Standardization for Data Forms
 *   JEG-0068: http://www.jabber.org/jeps/jep-0068.html (XForms-ish?) More on
 * 
 * filtering options:
 * http://www.jivesoftware.org/builds/smack/docs/latest/documentation/processing.html
 * 
 * eg new PacketIDFilter(sparqlRequest.getPacketID())); OK we want to hear about
 * Packets that are messages, and those that are IQs: PacketFilter filter = new
 * AndFilter(new PacketTypeFilter(Message.class),  new
 * PacketTypeFilter(IQ.class)); 
 * 
 * http://www.jivesoftware.org/builds/messenger/docs/latest/documentation/javadoc/org/jivesoftware/messenger/handler/IQHandler.html
 */

		// Edit these:
		// server_jid = "danbrickley@talk.google.com";
		// server_jid = "danbri@livejournal.com";
		// server_jid = "foaf2@jabber.org";
		// client_jid = "danbri@talk.google.com";
		// client_jid = "bandri@livejournal.com"; //f27
		// client_jid = "foaf@jabber.org";