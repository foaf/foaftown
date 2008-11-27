import java.io.*;
import java.util.*;
import com.hp.hpl.jena.rdf.model.*;
import com.hp.hpl.jena.query.*;

public class QdosUser{

/**

Main method demonstrating getContacts.

*/


public static void main(String[] args){

 String lookup=null;
 String flag=null;
 if(args.length > 1){
  flag=args[0];
  lookup=args[1];
  QdosUser u = new QdosUser();

  try{
    if(flag.equals("--contacts")){
      u.getContacts(lookup);
      System.out.println("Contacts: "+u.getContactsReferencedMap());
    }else{
      System.out.println("Usage: sh qdosuser.sh <flag> <foafFileUserID|email|mboxsha1sum|homepage>");
      System.out.println("Available flag is --contacts");
    }
   }catch(Exception e){
    System.out.println("Problem "+e);
   }
 }else{
   System.out.println("Usage: sh qdosuser.sh <flag> <foafFileUserID|email|mboxsha1sum|homepage>");
   System.out.println("Available flag is --contacts");
 }

}

/**

Internal objects that get filled and returned.

*/

Map attributes=new HashMap();
Map contactsReferencedMap=new HashMap();

/**

Get methods for the useful Objects.

*/

 public Map getAttributes(){
  return this.attributes;
 }
 
 public Map getContactsReferencedMap(){
  return this.contactsReferencedMap;
 }    
 


/**

Get the user's contacts from their foaf file, returning a map. 

*/


public QdosUser getContacts(String url) throws java.io.IOException{

 try{

 String qdosLookup="http://foaf.qdos.com/forward?";

  if(url.indexOf("#")==-1){
   qdosLookup=qdosLookup+"ifp=&";
  }

  url=url.replaceAll("#","%23");
  url=url.replaceAll("/","%2F");
  url=url.replaceAll(":","%3A");

  qdosLookup=qdosLookup+"path="+url;

  System.out.println("url is "+qdosLookup);

  Model model = ModelFactory.createDefaultModel();
  model.read(qdosLookup); 

  String queryString = 
  "PREFIX foaf:   <http://xmlns.com/foaf/0.1/> "+
  "select distinct ?fn ?nick ?weblog ?homepage ?mbox ?mboxsha1 where { "+
  "?x foaf:knows ?y . "+
  "optional {?y foaf:name ?fn}. "+
  "optional {?y foaf:nick ?nick}. "+
  "optional {?y foaf:mbox ?mbox}. "+
  "optional {?y foaf:weblog ?weblog}. "+
  "optional {?y foaf:homepage ?homepage}. "+
  "optional {?y foaf:mbox_sha1sum ?mboxsha1}. }";

  Query query = QueryFactory.create(queryString);
  QueryExecution qe = QueryExecutionFactory.create(query, model);
  ResultSet results = qe.execSelect();

  ArrayList<String> resultVars = new ArrayList<String>();

  int k = 0;
  for (Iterator j = results.getResultVars().iterator(); j.hasNext();) {
   resultVars.add(k, j.next().toString());
   k++;
  }

  while (results.hasNext()) {
   QuerySolution rs = (QuerySolution)results.nextSolution(); 
   Map m= new HashMap();
   String id=null;

   for (int i = 0; i < resultVars.size(); i++) { 
    String s=resultVars.get(i);
    Object v=rs.get(s);
    String r=null;
    if(v!=null){
      r=v.toString();
      m.put(s,r);
      if(id==null && (!s.equals("fn"))){
       id=r;
      }
    }
   }
   if(id!=null){
     contactsReferencedMap.put(id,m);
   }

  }

 qe.close();

 }catch(Exception e){
  System.out.println("problem: "+e);
  e.printStackTrace();
 }

return this;

}



}
