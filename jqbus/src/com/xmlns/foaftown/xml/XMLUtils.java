/*
 * Created on Apr 4, 2004, 3:33:51 PM by Ian
 *
 * I hereby abandon any property rights to this file,
 * and release the contents of this file into the
 * Public Domain. As with all the software in this
 * package, this file comes with NO WARRANTY
 * or guarantee of fitness for any purpose.
 *
 */
//package net.ex_337.gradient.util;
package com.xmlns.foaftown.xml;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

//import net.ex_337.GeneralRuntimeException;
//import net.ex_337._dev.DevelopmentMode;
//import net.ex_337.gradient.FailedDirectiveException;
import com.xmlns.foaftown.xml.*; // all of the above


import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.jaxen.JaxenException;
import org.jaxen.NamespaceContext;
import org.jaxen.XPath;
import org.jaxen.dom.DOMXPath;
import org.w3c.dom.CharacterData;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xmlpull.v1.XmlPullParserException;

/**
 * Static XML utility methods.
 */
public class XMLUtils {

	private static OutputFormat xmppBoundFragmentOutputFormat;
	private static OutputFormat niceOutputFormat;

	private static DocumentBuilderFactory docBuilderFactory;
	private static DocumentBuilder docBuilder;

	/**
	 * A generic factory document for use in creating Elements
	 * etc. that will never be attached to a document.
	 */
	public static final Document FACTORY_DOCUMENT;

	/**
	 * The namespace used by the W3C SVG 1.0 specification.
	 * Value is http://www.w3.org/2000/svg
	 */
	public static final String SVG_NAMESPACE = "http://www.w3.org/2000/svg";


	/**
	 * The element name for an Gradient document request extension.
	 * Currently "request".
	 */
	public static final String DOC_REQUEST = "request";

	/**
	 * This is the namespace used for tagging Gradient document modification
	 * directives, Message/Presence target path/document request extensions,
	 * and thread attributes on outgoing IQs.
	 *
	 * Currently http://ex-337.net/xmlns/xmpp/gradient.
	 */
	public static final String GRADIENT_NAMESPACE = "http://ex-337.net/xmlns/xmpp/gradient";

	/**
	 * The element name for an XMPP extension enclosing a set of document modification directives.
	 * Currently "directive-set".
	 */
	public static final String DIRECTIVE_SET = "directive-set";

	/**
	 * The element name for a Gradient of an document modification directive.
	 * Currently "directive".
	 */
	public static final String DIRECTIVE = "directive";

	/**
	 * The element name for a Gradient XMPP extension specifying a target path for a given Message/Presence
	 * stanza.
	 * Currently "target-path".
	 */
	public static final String TARGET_PATH = "target-path";

	/**
	 * The element name for the response to an a Gradient document request.
	 * Currently "response".
	 */
	public static final String DOC_RESPONSE = "response";

	/**
	 * A Pull-API to DOM converter. Since it's stateless,
	 * and we use one all over the place, it saves is trouble
	 * by putting one here.
	 */
	public static DOM2XmlPullBuilder PULL2DOM = new DOM2XmlPullBuilder();

	static {
		xmppBoundFragmentOutputFormat = new OutputFormat();
		xmppBoundFragmentOutputFormat.setIndenting(false);
		xmppBoundFragmentOutputFormat.setOmitComments(true);
		xmppBoundFragmentOutputFormat.setOmitDocumentType(false);
		xmppBoundFragmentOutputFormat.setOmitXMLDeclaration(true);
		
		niceOutputFormat = new OutputFormat();
		niceOutputFormat.setIndenting(true);
		niceOutputFormat.setOmitComments(true);
		niceOutputFormat.setOmitDocumentType(false);
		niceOutputFormat.setOmitXMLDeclaration(true);

		docBuilderFactory = DocumentBuilderFactory.newInstance();
		docBuilderFactory.setValidating(false);
		docBuilderFactory.setExpandEntityReferences(false);
		docBuilderFactory.setIgnoringComments(true);
		docBuilderFactory.setIgnoringElementContentWhitespace(true);
		docBuilderFactory.setNamespaceAware(true);

		try {
			docBuilder = docBuilderFactory.newDocumentBuilder();
		} catch(javax.xml.parsers.ParserConfigurationException pce) {
			throw new GeneralRuntimeException(pce);
		}

		FACTORY_DOCUMENT = newDocument();

	}

	/**
	 * Returns the String serialisation of an Element. The output format
	 * omits indentation, comments, and DTD/XML declarations.
	 *
	 * @param element the element to serialise
	 * @return the string representation of the element, and all it's child nodes.
	 */
	public static String serialiseElementNicely(Element element) {
		try {
			StringWriter result = new StringWriter();
			XMLSerializer xmlSerializer = new XMLSerializer(result, niceOutputFormat);
			xmlSerializer.setNamespaces(true);
			xmlSerializer.serialize(element);
			return result.toString();
		} catch(IOException e) {
			throw new GeneralRuntimeException(e);
		}
	}

	/**
	 * Returns the String serialisation of an Element. The output format
	 * omits comments, and DTD/XML declarations, but indented
	 *
	 * @param element the element to serialise
	 * @return the string representation of the element, and all it's child nodes.
	 */
	public static String serialiseElement(Element element) {
		try {
			StringWriter result = new StringWriter();
			XMLSerializer xmlSerializer = new XMLSerializer(result,xmppBoundFragmentOutputFormat);
			xmlSerializer.setNamespaces(true);
			xmlSerializer.serialize(element);
			return result.toString();
		} catch(IOException e) {
			throw new GeneralRuntimeException(e);
		}
	}
	
	/**
	 * Creates a new Document. Ridiculously slow the first time, only used in test classes here.
	 * @return a new Document.
	 */
	public static Document newDocument() {
		return docBuilder.newDocument();
	}

	/**
	 *
	 * For some reason this is really, really slow.
	 * Like, 3 seconds for a simple FACTORY_DOCUMENT.
	 *
	 * Generally used in debugging, examples and tests.
	 *
	 * @param input the XML input stream
	 * @return a loaded Document.
	 */
	public static Document loadDocument(InputStream input) {
		try {
			return docBuilder.parse(input);
		} catch(IOException e) {
			return null;
		} catch(SAXException e) {
			return null;
		}
	}

	/**
	 * Returns the document element. Owner document is FACTORY_DOCUMENT.
	 * Really, really slow.
	 * @param input the inputstream containg an XML document.
	 * @return the root element.
	 */
	public static Element loadElement(InputStream input) {
		return (Element)XMLUtils.FACTORY_DOCUMENT.importNode(loadDocument(input).getDocumentElement(), true);
	}

	/**
	 * Returns a List of all child Elements of the given Element.
	 *
	 * @param element the element from which to retrieve child elements
	 * @return a List of child Elements.
	 * @throws NullPointerException if the element is null.
	 */
	public static List getChildElements(Element element) {
		if(element == null) throw new NullPointerException("Tried to get child elements on a null element");

		List result = new ArrayList();

		NodeList children = element.getChildNodes();

		for( int i = 0; i != children.getLength(); i++ ) {
			if(children.item(i).getNodeType() == Node.ELEMENT_NODE) {
				result.add(children.item(i));
			}
		}

		return result;
	}

	/**
	 * Removes all elements with the given namespace from the provided list.
	 * Assumes all list objects are Elements.
	 * @param elements the list of elements
	 * @param namespace the namespace of the elements to remove
	 * @return the list, minus elements of the given namespace.
	 * @throws ClassCastException if any of the list members are not Elements 
	 */
	public static List removeElementsWithNamespace(List elements, String namespace) {
		for(Iterator i = elements.iterator(); i.hasNext();) {
			Element next = (Element)i.next();
			if(next.getNamespaceURI().equals(namespace)) i.remove();
		}

		return elements;
	}

	/**
	 * Removes all elements with the given tag name from the given list
	 * @param elements the list of elements
	 * @param tagName the tag name
	 * @return thelist, minus elements with the specified name
	 * @throws ClassCastException if any of the list members are not Elements 
	 */
	public static List removeElementsWithTagName(List elements, String tagName) {
		for(Iterator i = elements.iterator(); i.hasNext();) {
			Element next = (Element)i.next();
			if(next.getTagName().equals(tagName)) i.remove();
		}

		return elements;
	}

	
	/**
	 * Returns all child character data of the given element, including CDATA sections but NOT entity references.
	 * @param parentEl the parent element.
	 * @return the child character data of the element, or null if the element is null.
	 */
	static public String getChildCharacterData(Element parentEl) {
		if (parentEl == null) {
			return null;
		}

		Node tempNode = parentEl.getFirstChild();
		StringBuffer strBuf = new StringBuffer();
		CharacterData charData;

		while (tempNode != null) {
			switch (tempNode.getNodeType()) {
				case Node.TEXT_NODE :
				case Node.CDATA_SECTION_NODE : charData = (CharacterData)tempNode;
				strBuf.append(charData.getData());
				break;
//				case Node.ENTITY_REFERENCE_NODE : strBuf.append("&").append(tempNode.getNodeName()).append(";");


			}
			tempNode = tempNode.getNextSibling();
		}
		return strBuf.toString();
	}

	/**
	 * Returns a Map of all attributes of the given element with the given namespace.
	 * Why can we not create our own NamedNodeMaps? This would save trouble.
	 * @param element the elment from which to retrieve the attributes.
	 * @param namespaceURI the namespace of the attributes to retrieve.
	 * @return a Map containing the attributes names and their values.
	 */
	public static Map getAttributesWithNS(Element element, String namespaceURI) {
		Map result = new HashMap();

		NamedNodeMap attributes = element.getAttributes();

		if(attributes == null) return result;

		for(int i = 0; i != attributes.getLength(); i++) {
			Node attribute = attributes.item(i);

			if(namespaceURI == null && attribute.getNamespaceURI() == null) {
				result.put(attribute.getNodeName(), attribute.getNodeValue());
			} else if(attribute.getNamespaceURI() != null && attribute.getNamespaceURI().equals(namespaceURI)) {
				result.put(attribute.getNodeName(), attribute.getNodeValue());
			}
		}

		return result;
	}

	/**
	 * This is an ugly hack, there must be a nicer way to do it.
	 * Using getPrefix doesn't work because it stops us from getting
	 * xmlns: attributes, which is what I'm using this for. Using
	 * getNamespace doesn't seem to work on xmlns attributes either.
	 * Trims the prefix on the map key.
	 * @param element the element from which to retrieve the attributes.
	 * @param prefix the prefix of the attributes to retrieve
	 * @return a Map containing the attributes names and their values.
	 */
	public static Map getAttributesWithPrefix(Element element, String prefix) {
		Map result = new HashMap();

		prefix += ":";

		NamedNodeMap attributes = element.getAttributes();

		if(attributes == null) return result;

		for(int i = 0; i != attributes.getLength(); i++) {
			Node attribute = attributes.item(i);

			if(attribute.getNodeName().startsWith(prefix)) {
				result.put(attribute.getNodeName().substring(prefix.length()), attribute.getNodeValue());
			}
		}

		return result;
	}

	/**
	 * Debug method. Prints to System.out each Element in the given list.
	 * @param l1 the list of elements to print.
	 */
	public static void printElements(List l1) {

		for(Iterator i = l1.iterator(); i.hasNext();) {
			Object o = i.next();
			//if(o instanceof Element)Logger.getInstance().log("l1: "+serialiseElement((Element)o));
		}
	}

	/**
	 * Compiles the given XPath expression with the given namepace context, and
	 * returns a list of all matching nodes in the given document.
	 * @param document the document to run the XPath expression against.
	 * @param context the namespace context to use.
	 * @param xPathExpression the XPath expression to use.
	 * @return a List of all nodes matching the XPath expression.
	 * @throws FailedDirectiveException if the XPath exrpression is malformed.
	 */
	public static List getMatchingNodes(Document document, NamespaceContext context, String xPathExpression) {

		List result;

		try {

			XPath xPath = new DOMXPath(xPathExpression);
			if(context != null)xPath.setNamespaceContext(context);
			result = xPath.selectNodes(document);

		} catch(JaxenException je) {
			throw new FailedDirectiveException("Bad XPath expression in directive:"+je.getMessage(), je);
		}

		return result;
	}

	/**
	 * Appends the nodes in nodeList to each Node in the document matching the given XPath expression using the given namespace context.
	 * @param document the document to run the XPath expression against.
	 * @param context the namespace context of the XPath expression.
	 * @param xPathExpression the XPath expression that retrieves the list of Nodes from the Document.
	 * @param nodeList the list of nodes to append to each result of the XPath expression.
	 */
	public static void appendTo(Document document, NamespaceContext context, String xPathExpression, List nodeList) {

		List targetNodes = getMatchingNodes(document, context, xPathExpression);

		if(targetNodes == null || nodeList == null) {
			throw new FailedDirectiveException("Tried to append, but targetNodes="+targetNodes+" and dataElements="+nodeList);
		}

		if(DevelopmentMode.XMLUtils_DEBUG) {
			printElements(targetNodes);
			printElements(nodeList);
		}

		if(targetNodes.size() == 0 || nodeList.size() == 0) return;

		Node target, dataNode;

		target = dataNode = null;

		for(Iterator targets = targetNodes.iterator(); targets.hasNext(); ) {

			target = (Node)targets.next();

			for(Iterator dataIterator = nodeList.iterator(); dataIterator.hasNext(); ) {
				dataNode = (Node)dataIterator.next();
				target.appendChild(document.importNode(dataNode, true));
			}
		}
	}

	/**
	 * Inserts the nodes in nodeList before each Node in the document matching the given XPath expression using the given namespace context.
	 * @param document the document to run the XPath expression against.
	 * @param context the namespace context of the XPath expression.
	 * @param xPathExpression the XPath expression that retrieves the list of Nodes from the Document.
	 * @param nodeList the list of nodes to insert before each result of the XPath expression.
	 */
	public static void insertBefore(Document document, NamespaceContext context, String xPathExpression, List nodeList) {

		List targetNodes = getMatchingNodes(document, context, xPathExpression);

		if(targetNodes == null || nodeList == null) {
			throw new FailedDirectiveException("Tried to insertBefore, but targetNodes="+targetNodes+" and dataElements="+nodeList);
		}

		if(DevelopmentMode.XMLUtils_DEBUG) {
			printElements(targetNodes);
			printElements(nodeList);
		}

		if(targetNodes.size() == 0 || nodeList.size() == 0) return;

		Node target, dataNode;

		target = dataNode = null;

		for(Iterator targets = targetNodes.iterator(); targets.hasNext(); ) {
			target = (Node)targets.next();

			for(Iterator dataIterator = nodeList.iterator(); dataIterator.hasNext(); ) {
				dataNode = (Node)dataIterator.next();

				if(DevelopmentMode.XMLUtils_DEBUG) {
					// Logger.getInstance().log("target="+target);
					// Logger.getInstance().log("data="+dataNode);
				}

				Node parent = target.getParentNode();
				if(parent != null)parent.insertBefore(document.importNode(dataNode, true), target);
			}
		}
	}

	/**
	 * Replaces each node in the document matching the given XPath expression with the given node.
	 * @param document the document to run the XPath expression against.
	 * @param context the namespace context of the XPath expression.
	 * @param xPathExpression the XPath expression that retrieves the list of Nodes from the Document.
	 * @param replacementNode the node with which to replace each result of the XPath expression.
	 */
	public static void replace(Document document, NamespaceContext context, String xPathExpression, Node replacementNode) {

		List targetNodes = getMatchingNodes(document, context, xPathExpression);

		if(targetNodes == null || replacementNode == null) {
			throw new FailedDirectiveException("Tried to insertBefore, but targetNodes="+targetNodes+" and element="+replacementNode);
		}

		if(DevelopmentMode.XMLUtils_DEBUG)printElements(targetNodes);

		if(targetNodes.size() == 0) return;

		Node target;

		target = null;

		for(Iterator targets = targetNodes.iterator(); targets.hasNext(); ) {
			target = (Node)targets.next();
			Node parent = target.getParentNode();
			if(parent != null)parent.replaceChild(document.importNode(replacementNode, true), target);
		}
	}

	/**
	 * Removes each node matching the given XPath expression in the given document.
	 * @param document the document to run the XPath expression against.
	 * @param context the namespace context of the XPath expression.
	 * @param xPathExpression the XPath expression that retrieves the list of Nodes to remove from the Document.
	 */
	public static void remove(Document document, NamespaceContext context, String xPathExpression) {

		List targetNodes = getMatchingNodes(document, context, xPathExpression);

		if(targetNodes.size() == 0) return;

		Node target = null;

		if(DevelopmentMode.XMLUtils_DEBUG)printElements(targetNodes);

		for(Iterator targets = targetNodes.iterator(); targets.hasNext(); ) {
			target = (Node)targets.next();
			Node parent = target.getParentNode();
			if(parent != null) parent.removeChild(target);
		}
	}

	/**
	 * Uses the default DOM2PullParser to retrieve a DOM Element from an InputStream.
	 * The parent document will be FACTORY_DOCUMENT. Aw, a brand new baby node! Congratulations!
	 *
	 * @param input the InputStream from which to read the element markup
	 * @return the Element produced by the DOM2PullParser.
	 * @throws GeneralRuntimeException if an IOException or XmlPullParserException is thrown during parsing.
	 */
	public static Element getElementFromStream(InputStream input) {
		try {
			return PULL2DOM.parse(new InputStreamReader(input, "UTF-8"));
		} catch (XmlPullParserException e) {
			throw new GeneralRuntimeException(e);
		} catch (IOException e) {
			throw new GeneralRuntimeException(e);
		}
	}

	/**
	 * Uses the default DOM2PullParser to retrieve a DOM Element from a String
	 * The parent document will be FACTORY_DOCUMENT.
	 *
	 * @param string the String containing the element markup
	 * @return the Element produced by the DOM2PullParser.
	 * @throws GeneralRuntimeException if an IOException or XmlPullParserException is thrown during parsing.
	 */
	public static Element getElementFromString(String string) {
		try {
			return PULL2DOM.parse(new StringReader(string));
		} catch (XmlPullParserException e) {
			throw new GeneralRuntimeException(e);
		} catch (IOException e) {
			throw new GeneralRuntimeException(e);
		}
	}

	/**
	 * Tests whatever method I last added to this class.
	 * @param args the arguments, if you insist.
	 */
	public static void main(String[] args) {

		Document doc = newDocument();

		Element el = doc.createElement("test");
		el.setAttribute("testatt1", "testattval1");
		el.setAttribute("testatt2", "testattval2");
		el.setAttribute("testatt3", "testattval3");
		el.setAttribute("xmlns:google", "http://google.com");
		el.setAttributeNS("http://foo.com", "foo", "bar");
		el.setAttributeNS("http://foo.com", "blart", "fnoo");

//		EntityReference entityRef1 = doc.createEntityReference("lt");
//		EntityReference entityRef2 = doc.createEntityReference("gt");
//		EntityReference entityRef3 = doc.createEntityReference("amp");
//
//		el.appendChild(entityRef1);
//		el.appendChild(entityRef2);
//		el.appendChild(entityRef3);
//		Element el2 = doc.createElementNS("http://google.com", "google:search");
//		el2.setAttributeNS("http://google.com", "search", "true");
//		el2.setAttribute("site", "slashdot.org");
//
//		el.appendChild(el2);

		//Logger.getInstance().log(getAttributesWithPrefix(el, "xmlns"));

		//Logger.getInstance().log(serialiseElement(el));
	}
}
