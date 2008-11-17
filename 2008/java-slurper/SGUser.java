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
  String lookup2="6de4ff27ef927b9ba21ccc88257e41a2d7e7d293";
  String recursive="false";

  if(args.length > 0){
   lookup=args[0];
  }
  if(args.length > 1){
   lookup=args[0];
   recursive=args[1];
  }
  if(args.length > 2){
   lookup=args[0];
   recursive=args[1];
   lookup2=args[2];
  }

  SGUser u = new SGUser();
  try{

  boolean f=u.hasPath(lookup,lookup2);

  System.out.println("Path: "+f);
//   u.getDetails(lookup,recursive);
//  System.out.println("Attributes: "+u.getAttributes());
//   u.getContacts(lookup,recursive);
//  System.out.println("Contacts: "+u.getContactsReferencedMap());

  //goes for 2 levels
  //System.out.println("Contacts: "+u.getFoafs());

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
 Map contactsReferencedMap=new HashMap();
 private Map nodes=null;
 List foafs=new ArrayList();

/**

Get methods for the useful Maps.

*/

 public Map getAttributes(){
  return this.attributes;
 }

 public List getContactsReferenced(){
  return this.contactsReferenced;
 }

 public List getFoafs(){
  return this.foafs;
 }

 public Map getContactsReferencedMap(){
  return this.contactsReferencedMap;
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

  this.getMultipleDetails(contactsReferenced);

  return this;

 }

/**

Goes back to the API and gets the names of the users from a list.

*/

 public void getMultipleDetails(List people) throws java.io.IOException{

   List peopleShorter = new ArrayList();
   String urlStart="http://socialgraph.apis.google.com/lookup?pretty=1&edo=1";

   String qstring="";

   //max 15 queries from the api (it seems; docs say 50)
   int max=15;

   //construct query string
   for(int i=0;i<people.size();i++){
    String id=people.get(i).toString();
    if(i<max){
     id=id.replaceAll("\\?","%3F");
     id=id.replaceAll("=","%3D");
     qstring=qstring+","+id;
    }else{
     peopleShorter.add(id);
    }
   }

   URL u=new URL(urlStart+"&q="+qstring);

   JsonFactory jf = new JsonFactory(); 
   JavaTypeMapper jtm=new JavaTypeMapper();
   jtm.setDupFieldHandling(BaseMapper.DupFields.valueOf("USE_FIRST"));

   Map hash = (Map)jtm.read(jf.createJsonParser(u));
   Map friendNodes  = (Map) hash.get("nodes");

   //for each of these cannonical mappings get the name and add it to the map
   //contactsReferencedMap

  for ( Iterator<String> nodesIt = friendNodes.keySet().iterator(); nodesIt.hasNext(); ) {
   String str = nodesIt.next();
   Map vals = (Map)friendNodes.get(str);
   for ( Iterator<String> attsIt = vals.keySet().iterator(); attsIt.hasNext(); ) {
    String str2 = attsIt.next();
    if(str2.equals("attributes")){
      LinkedHashMap vals2 = (LinkedHashMap)vals.get(str2);
      if(str.indexOf("sgn://mboxsha1/?pk=")!=-1){
        str=str.substring(19);
      }
      contactsReferencedMap.put(str,vals2);
    }
    if(str2.equals("nodes_referenced")){
      LinkedHashMap vals22 = (LinkedHashMap)vals.get(str2);

      for ( Iterator<String> contactsIt2 = vals22.keySet().iterator();contactsIt2.hasNext(); ) {

       String str3 = contactsIt2.next();
       Map vals3 = (Map)vals22.get(str3);
       for ( Iterator<String> contactsTypesIt2 = vals3.keySet().iterator(); contactsTypesIt2.hasNext(); ) {
         String str4 = contactsTypesIt2.next();
         List vals4 = (List)vals3.get(str4);
         if(!vals4.contains("me")){
           if(str3.indexOf("sgn://mboxsha1/?pk=")!=-1){
            str3=str3.substring(19);
           }
           this.foafs.add(str3);
         }
       }
      }
    }
   }

  }


  if(people.size()>max){
    //System.out.println("XXXXXXXXXXXXXX recursing at "+peopleShorter.size());
    for(int j=0;j<max;j++){
      String key=people.get(j).toString();
      if(key.indexOf("sgn://mboxsha1/?pk=")!=-1){
        key=key.substring(19);
      }
      if(!contactsReferencedMap.containsKey(key)){
        contactsReferencedMap.put(key,new LinkedHashMap());
        if(key.indexOf("sgn://mboxsha1/?pk=")!=-1){
          key=key.substring(19);
        }
        this.foafs.add(key);
      }
    }
    this.getMultipleDetails(peopleShorter);
  }

 }


/**

Path thingy

*/

public boolean hasPath(String id1, String id2) throws
java.io.IOException{

 this.getDetails(id1,"true");
 this.getContacts(id2,"true");

  if(this.foafs.contains(id2)){
   return true;
  }else{
   return false;
  }
}




}
