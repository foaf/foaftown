import org.codehaus.jackson.*;
import org.codehaus.jackson.map.*;
import java.util.*;
import java.io.*;
import java.net.*;


public class SGUser{


/**

Main method illustrates the use of getDetails.

*/

 public static void main(String[] args){

  String lookup="danbri.org";
  String recursive="false";

  if(args.length > 0){
   lookup=args[0];
  }
  if(args.length > 1){
   lookup=args[0];
   recursive=args[1];
  }

  SGUser u = new SGUser();
  try{
   u.getDetails(lookup,recursive);
   System.out.println("Attributes: "+u.getAttributes());
   u.getContacts(lookup,recursive);
   System.out.println("Contacts: "+u.getContactsReferenced());
  }catch(Exception e){
   System.out.println("problem "+e);
   e.printStackTrace();
  }
 }

/** 

Two useful Maps for the user:
 * attributes are thing like fn (first name), rss
 * contactsReferenced are a list of IDs for contacts (urls, mboxsha1sum, mbox)
*/

 Map attributes=new HashMap();
 List contactsReferenced=new ArrayList();
 private Map nodes=null;

/**

Get methods for the useful Maps.

*/

 public Map getAttributes(){
  return this.attributes;
 }

 public List getContactsReferenced(){
  return this.contactsReferenced;
 }


/**

Method for getting the url and parsing it.

*/

 private void getNodes(String userID,String recursive) throws java.io.IOException{

  if(this.nodes==null){
   String urlStart="http://socialgraph.apis.google.com/lookup?pretty=1&edo=1";
   if(recursive!=null && recursive.equals("true")){
   urlStart=urlStart+"&fme=1";
   }

   URL u=new URL(urlStart+"&q="+userID);

   JsonFactory jf = new JsonFactory(); 
   JavaTypeMapper jtm=new JavaTypeMapper();
   jtm.setDupFieldHandling(BaseMapper.DupFields.valueOf("USE_FIRST"));

   Map hash = (Map)jtm.read(jf.createJsonParser(u));

   this.nodes = (Map) hash.get("nodes");
  }

 }


/**

Get the details for the user.

The aim is to get minimal useful information about the user from the
google social graph. It looks recursively for attributes unless the
second argment is false, but takes the first ones if there are duplicates
(since ordering doesn't seem to put the requested node first this may
not be helpful).

*/

 public SGUser getDetails(String userID,String recursive) throws java.io.IOException{

  this.getNodes(userID,recursive);

  //for each node get the attributes and add them in

  for ( Iterator<String> nodesIt = nodes.keySet().iterator(); nodesIt.hasNext(); ) {
   String str = nodesIt.next();
   Map vals = (Map)nodes.get(str);
   for ( Iterator<String> attsIt = vals.keySet().iterator(); attsIt.hasNext(); ) {
    String str2 = attsIt.next();
    if(str2.equals("attributes")){
      LinkedHashMap vals2 = (LinkedHashMap)vals.get(str2);
      attributes.putAll(vals2);
    }
   }
  }
  return this;
 }

/**

Get the contacts for the user.

It looks recursively for nodes_referenced unless the second argument is
false, but takes the first ones if there are duplicates (since ordering
doesn't seem to put the requested node first this may not be helpful).
It only returns the ones that are not 'me'.

*/

 public SGUser getContacts(String userID, String recursive) throws java.io.IOException{

  this.getNodes(userID,recursive);

  //for each node get the attributes and add them in

  for ( Iterator<String> nodesIt = nodes.keySet().iterator(); nodesIt.hasNext(); ) {
   String str = nodesIt.next();
   Map vals = (Map)nodes.get(str);
   for ( Iterator<String> attsIt = vals.keySet().iterator(); attsIt.hasNext(); ) {
    String str2 = attsIt.next();
    if(str2.equals("nodes_referenced")){
      LinkedHashMap vals2 = (LinkedHashMap)vals.get(str2);
      for ( Iterator<String> contactsIt = vals2.keySet().iterator(); contactsIt.hasNext(); ) {
       String str3 = contactsIt.next();
       Map vals3 = (Map)vals2.get(str3);

       for ( Iterator<String> contactsTypesIt = vals3.keySet().iterator(); contactsTypesIt.hasNext(); ) {
         String str4 = contactsTypesIt.next();
         List vals4 = (List)vals3.get(str4);
         if(!vals4.contains("me")){
           contactsReferenced.add(str3);
         }
       }

      }
    }
   }
  }
  return this;

 }

}
