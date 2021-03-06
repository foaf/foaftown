import java.io.*;
import java.util.*;
import com.hp.hpl.jena.rdf.model.*;
import com.hp.hpl.jena.query.*;

public class FoafUser{

/**

Main method demonstrating getDetails and getContacts.

*/


public static void main(String[] args){

 String lookup=null;
 String flag=null;
 if(args.length > 1){
  flag=args[0];
  lookup=args[1];
  FoafUser u = new FoafUser();

  try{
    if(flag.equals("--details")){
     u.getDetails(lookup);
     System.out.println("Attributes: "+u.getAttributes());
    }else if(flag.equals("--contacts")){
     u.getContacts(lookup);
     System.out.println("Contacts: "+u.getContactsReferencedMap());
    }else{
      System.out.println("Usage: sh foafuser.sh <flag> <foafFileURL");
      System.out.println("Available flags are --details and --contacts");
    }
   }catch(Exception e){
    System.out.println("Problem "+e);
   }
 }else{
   System.out.println("Usage: sh foafuser.sh <flag> <foafFileURL>");
   System.out.println("Available flags are --details and --contacts");
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

Get the details of a user - it's based on 

http://code.google.com/apis/socialgraph/docs/attributes.html

but I've added weblog and homepage as well, and there's no url, profile,
foaf, rss or atom. So not very like it at the moment :-/.

You have to pass it a foaf file explaicitly.

*/


public FoafUser getDetails(String url) throws java.io.IOException{

try{

 Model model = ModelFactory.createDefaultModel();
 model.read(url); 

 // Create a new query
 String queryString = 
  "PREFIX foaf:   <http://xmlns.com/foaf/0.1/> "+
  "select distinct ?photo ?fn ?weblog ?homepage ?mbox ?mboxsha1 where { "+
  "?x foaf:knows ?y . "+
  "optional {?x foaf:img ?photo}. "+
  "optional {?x foaf:depiction ?photo} . "+
  "optional {?x foaf:name ?fn}. "+
  "optional {?x foaf:weblog ?weblog}. "+
  "optional {?x foaf:homepage ?homepage}. "+
  "optional {?x foaf:mboxsha1 ?mboxsha1}. "+
  "optional {?x foaf:mbox ?mbox}.} ";

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
   for (int i = 0; i < resultVars.size(); i++) {  
    String s=resultVars.get(i);
    Object v=rs.get(s);
    String r=null;
    if(v!=null){
      r=v.toString();
      attributes.put(s,r);
    }
   }
  }

 qe.close();

 }catch(Exception e){
  System.out.println("problem: "+e);
  e.printStackTrace();
 }

return this;

}


/**

Get the user's contacts from their foaf file, returning a map. 

*/


public FoafUser getContacts(String url) throws java.io.IOException{

 try{

 Model model = ModelFactory.createDefaultModel();
 model.read(url); 

 String queryString = 
  "PREFIX foaf:   <http://xmlns.com/foaf/0.1/> "+
  "select distinct ?fn ?weblog ?homepage ?mbox ?mboxsha1 where { "+
  "?x foaf:knows ?y . "+
  "optional {?y foaf:name ?fn}. "+
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
