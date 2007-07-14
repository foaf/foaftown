/* -*-             c-basic-offset: 4; indent-tabs-mode: nil; -*-  //------100-columns-wide------>|*/
// for license please see accompanying LICENSE.txt file (available also at http://www.xmlpull.org/)

//was package org.xmlpull.v1.dom2_builder;

//package net.ex_337.gradient.util;
package com.xmlns.foaftown.xml;


import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;

//import net.ex_337._dev.DevelopmentMode;

import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Text;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

/**
 * Taken from org.xmlpull.v1.dom2_builder, modified by Ian 03/04/2004 to fix bugs, use a static document, etc.
 *
 * <strong>Simplistic</strong> DOM2 builder that should be enough to do support most cases.
 * Requires JAXP DOMBuilder to provide DOM2 implementation.
 * <p>NOTE:this class is stateless PARSER_FACTORY and it is safe to share between multiple threads.
 * </p>
 * Changed a little to fix bugs in namespace scope computation. Leaves some funny
 * artifacts in XML serialised from XML loaded from this class (e.g. namespaces declared
 * that are not referred to in child XML), but it works.
 * @author <a href="http://www.extreme.indiana.edu/~aslom/">Aleksander Slominski</a>, Modified by Ian
 */
public class DOM2XmlPullBuilder {

	private static XmlPullParserFactory PARSER_FACTORY = null;
	
	static {
		
		try {
			PARSER_FACTORY = XmlPullParserFactory.newInstance("org.xmlpull.mxp1.MXParserFactory", null);
		} catch (XmlPullParserException e) {
		//	Logger.getInstance().log("Could not create XMLPullParser PARSER_FACTORY:"+e.getMessage(), e);
		} 
	}

    //protected XmlPullParser pp;
    //protected XmlPullParserFactory PARSER_FACTORY;

	/**
	 * The default constructor. You can use this if you like.
	 */
    public DOM2XmlPullBuilder() { //throws XmlPullParserException {
        //PARSER_FACTORY = XmlPullParserFactory.newInstance();
    }
    //public DOM2XmlPullBuilder(XmlPullParser pp) throws XmlPullParserException {
    //public DOM2XmlPullBuilder(XmlPullParserFactory PARSER_FACTORY)throws XmlPullParserException
    //{
    //    this.PARSER_FACTORY = PARSER_FACTORY;
    //}

    private XmlPullParser newParser() throws XmlPullParserException {
        
        return PARSER_FACTORY.newPullParser();
    }

    /**
     * Returns a single element. Asssumes that the reader contains "&lt;foo&gt;...&lt;/foo&gt;".
     *
     * @param reader the reader containing the input XML
     * @return the element contained by the reader.
     * @throws XmlPullParserException if the xml is malformed, or the parser chokes on something.
     * @throws IOException if the reader can't be read
     */
    public Element parse(Reader reader) throws XmlPullParserException, IOException {
        return parse(reader, XMLUtils.FACTORY_DOCUMENT);
    }

    /**
     * Returns a single element, using the given document as a PARSER_FACTORY.
     * @param reader the reader containing the input XML
     * @param factoryDocument the document to be used in creating elements
     * @return the element contained by the reader.
     * @throws XmlPullParserException if the xml is malformed, or the parser chokes on something.
     * @throws IOException if the reader can't be read
     */
    public Element parse(Reader reader, Document factoryDocument)
        throws XmlPullParserException, IOException
    {
        XmlPullParser pp = newParser();
        pp.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, true);
        pp.setInput(reader);
        pp.next();
        return parse(pp, factoryDocument);
    }


    /**
     * Returns an element from the XML Pull parser pp. Assumes that the parser is positioned at the start of an element.
     * @param pp the pull parser
     * @return the element
     * @throws XmlPullParserException if the XML is malformed
     * @throws IOException if a problem occurs with the underlying input source.
     */
    public Element parse(XmlPullParser pp) throws XmlPullParserException, IOException {
        Element root = parse(pp, XMLUtils.FACTORY_DOCUMENT);
        return root;
    }

    /**
     * Returns one element from a larger document. Assumes the parser is positioned at the beginning of the document.
     * @param pp the pull parser
     * @param factoryDocument the PARSER_FACTORY document used to create nodes.
     * @return the element.
     * @throws XmlPullParserException if the XML is malformed
     * @throws IOException if a problem occurs with the underlying input source.
     */
    public Element parse(XmlPullParser pp, Document factoryDocument)
        throws XmlPullParserException, IOException
    {
        BuildProcess process = new BuildProcess();
        return process.parseSubTree(pp, factoryDocument);
    }

    static class BuildProcess {
        private XmlPullParser pp;
        private Document factoryDocument;
        private boolean scanNamespaces = true;

        private BuildProcess() {
        }

        Element parseSubTree(XmlPullParser pullParser, Document document)
            throws XmlPullParserException, IOException
        {
            this.pp = pullParser;
            this.factoryDocument = document;
            return parseSubTree();
        }

        private Element parseSubTree()
            throws XmlPullParserException, IOException
        {
            pp.require( XmlPullParser.START_TAG, null, null);
            String name = pp.getName();
            String ns = pp.getNamespace(    );
            String prefix = pp.getPrefix();
            String qname = prefix != null ? prefix+":"+name : name;
            Element parent = factoryDocument.createElementNS(ns, qname);

            if(DevelopmentMode.DOM2XMLPullBuilder_DEBUG) {
            //	Logger.getInstance().log("Parsing tag "+name+", ns="+pp.getNamespace());
            }

            //declare namespaces - quite painful and easy to fail process in DOM2
            declareNamespaces(pp, parent);

            // process attributes
            for (int i = 0; i < pp.getAttributeCount(); i++)
            {
                String attrNs = pp.getAttributeNamespace(i);
                String attrName = pp.getAttributeName(i);
                String attrValue = pp.getAttributeValue(i);
                if(attrNs == null || attrNs.length() == 0) {
                    parent.setAttribute(attrName, attrValue);
                } else {
                    String attrPrefix = pp.getAttributePrefix(i);
                    String attrQname = attrPrefix != null ? attrPrefix+":"+attrName : attrName;
                    parent.setAttributeNS(attrNs, attrQname, attrValue);
                }
            }

            // process children
            while( pp.next() != XmlPullParser.END_TAG ) {
                if (pp.getEventType() == XmlPullParser.START_TAG) {
                    Element el = parseSubTree(pp, factoryDocument);

//			//<MOD BY="IAN" DATE="03/04/2004">
//
//                    if(el.getNamespaceURI() != null && el.getNamespaceURI().equals(XMPPUtils.GRADIENT_NAMESPACE) && el.getLocalName().equals("ref")) {
//
//			    Logger.getInstance().log("found our namespace, tagName="+el.getTagName()+", getLocalName="+el.getLocalName());
//
//
////				    Logger.getInstance().log("found entity reference");
////
//				 EntityReference entityRef = FACTORY_DOCUMENT.createEntityReference(el.getAttribute("entity"));
//
////				 parent.replaceChild(entityRef, el);
//				 parent.appendChild(entityRef);
////
////				 	Logger.getInstance().log("entityRef="+entityRef);
////
////				 parent.appendChild(text);
//
////			    else if(el.getLocalName().equals("att")) {
////
////				    Logger.getInstance().log("found escaped attribute");
////
//////				    el.normalize();
////				parent.setAttribute(el.getAttribute("name"), XMLUtils.getChildCharacterData(el));
////			    }
//
//
//		    } else
//    			    //</MOD>

                    parent.appendChild(el);

                } else if (pp.getEventType() == XmlPullParser.TEXT) {
                    String text = pp.getText();
                    Text textEl = factoryDocument.createTextNode(text);
                    parent.appendChild(textEl);
                } else {
                    throw new XmlPullParserException(
                        "unexpected event "+XmlPullParser.TYPES[ pp.getEventType() ], pp, null);
                }
            }
            pp.require( XmlPullParser.END_TAG, ns, name);
            return parent;
        }

        private void declareNamespaces(XmlPullParser pullParser, Element parent)
            throws DOMException, XmlPullParserException
        {
            if(scanNamespaces) {
                scanNamespaces = false;

                if(DevelopmentMode.DOM2XMLPullBuilder_DEBUG) {
                //	Logger.getInstance().log("depth:"+pullParser.getDepth());
                //	Logger.getInstance().log("namespace count:"+pullParser.getNamespaceCount(pullParser.getDepth()));

                	for(int i = 0; i != pullParser.getNamespaceCount(pullParser.getDepth()); i++) {
                		//Logger.getInstance().log("Namespace "+i+": "+pullParser.getNamespacePrefix(i)+"\t"+pullParser.getNamespaceUri(i));
                	}
                }



                int top = pullParser.getNamespaceCount(pullParser.getDepth()) - 1;
                // this loop computes list of all in-scope prefixes
                LOOP:
                for (int i = top; i >= pullParser.getNamespaceCount(0); --i)
                {
                    // make sure that no prefix is duplicated
                    String prefix = pullParser.getNamespacePrefix(i);

                    //<fix>

                    if(prefix == null) continue; //fuck you!
//                  if(prefix == null && !parent.hasAttribute("xmlns")) {
//            			declareOneNamespace(pullParser, i, parent);
//           		    } else

           		    	//</fix>


                    for (int j = top; j > i; --j)
                    {
                        if(prefix.equals(pullParser.getNamespacePrefix(j))) {
                            // prefix is already declared -- skip it
                            continue LOOP;
                        }
                    }
                    declareOneNamespace(pullParser, i, parent);
                }
            } else {
                for (int i = pullParser.getNamespaceCount(pullParser.getDepth()-1);
                     i < pullParser.getNamespaceCount(pullParser.getDepth());
                     ++i)
                {
                    declareOneNamespace(pullParser, i, parent);
                }
            }
        }

        private void declareOneNamespace(XmlPullParser pullParser, int i, Element parent)
            throws DOMException, XmlPullParserException {
            String xmlnsPrefix = pullParser.getNamespacePrefix(i);
            String xmlnsUri = pullParser.getNamespaceUri(i);
            String xmlnsDecl = (xmlnsPrefix != null) ? "xmlns:"+xmlnsPrefix : "xmlns";
            parent.setAttributeNS("http://www.w3.org/2000/xmlns/", xmlnsDecl, xmlnsUri);
        }
    }

//not used?
//    private static void assertEquals(String expected, String s) {
//        if((expected != null && !expected.equals(s)) || (expected == null && s == null)) {
//            throw new RuntimeException("expected '"+expected+"' but got '"+s+"'");
//        }
//    }
//    private static void assertNotNull(Object o) {
//        if(o == null) {
//            throw new RuntimeException("expected no null value");
//        }
//    }

    /**
     * Tests whatever it is I last did to this file.
     * @param args the arguments, such as they are.
     * @throws Exception for some reason.
     */
    public static void main(String[] args) throws Exception {
        DOM2XmlPullBuilder builder = new DOM2XmlPullBuilder();

//        final String XML = "<n:foo xmlns:n='uri1' xmlns:gradient='http://ex-337.net/xmpp/gradient'>"+
//
//        "<bar n:attr='test' xmlns='uri2'>"+
//        "<google />"+
//        "baz<grad:ref entity='latte' />foo"+
//        "</bar></n:foo>";


        Reader reader = new FileReader("D:\\Documents and Settings\\Ian\\Desktop\\test.xml");

        // create document

//        Element el1 = builder.parse(reader);
//	Logger.getInstance().log("doc="+doc);
//
//
//        // serialize and deserialzie
//        StringWriter sw = new StringWriter();
//
//        // requires JAXP
//        //        TransformerFactory xformFactory
//        //            = TransformerFactory.newInstance();
//        //        Transformer idTransform = xformFactory.newTransformer();
//        //        Source input = new DOMSource(doc1);
//        //        Result output = new StreamResult(sw);
//        //        idTransform.transform(input, output);
//
//        //OutputFormat fmt = new OutputFormat();
//        //XMLSerializer serializer = new XMLSerializer(sw, null);
//        //serializer.serialize(doc1);
//        //sw.close();
//        //String serialized = sw.toString();
//        //Logger.getInstance().log("serialized="+serialized);
//
//        reader = new StringReader(XML);
////
////        // reparse
////
        Element el2 = builder.parse(reader);
//
//        // check that what was written is OK
//
//        Element root = el2; //doc2.getDocumentElement();
//        //Logger.getInstance().log("root="+root);
//        Logger.getInstance().log ("root ns=" + root.getNamespaceURI() + ", localName=" +root.getLocalName());
//        assertEquals("uri1", root.getNamespaceURI());
//        assertEquals("foo", root.getLocalName());
//
//        NodeList children = root.getElementsByTagNameNS("*","bar");
//        Element bar = (Element)children.item(0);
//        Logger.getInstance().log ("bar ns=" + bar.getNamespaceURI() + ", localName=" +bar.getLocalName());
//        assertEquals("uri2", bar.getNamespaceURI());
//        assertEquals("bar", bar.getLocalName());
//
//        //
//        String attrValue = bar.getAttributeNS("uri1", "attr");
//        assertEquals("test", attrValue);
//        Attr attr = bar.getAttributeNodeNS("uri1", "attr");
//        assertNotNull(attr);
//        assertEquals("uri1", attr.getNamespaceURI());
//        assertEquals("attr", attr.getLocalName());
//        assertEquals("test", attr.getValue());
//
//
//        Text text = (Text)bar.getFirstChild();
//        Logger.getInstance().log("text="+text.getNodeValue());
//        assertEquals("baz", text.getNodeValue());

        // Logger.getInstance().log(XMLUtils.serialiseElement(el2));

    }

}




