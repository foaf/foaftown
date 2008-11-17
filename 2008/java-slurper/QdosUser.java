import java.io.*;
import java.util.*;
import com.hp.hpl.jena.rdf.model.*;
import com.hp.hpl.jena.query.*;

public class QdosUser{

/**

Main method demonstrating getDetails and getContacts.

*/


public static void main(String[] args){

 String lookup="danbri@danbri.org";
 if(args.length > 0){
  lookup=args[0];
 }

 try{
  QdosUser u = new QdosUser();
//  u.getDetails(lookup);
//  System.out.println("Attributes: "+u.getAttributes());
  u.getContacts(lookup);
  System.out.println("Contacts: "+u.getContactsReferencedMap());

 }catch(Exception e){
  System.out.println("problem "+e);
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


public QdosUser getDetails(String url) throws java.io.IOException{

try{

 String qdosLookup="http://foaf.qdos.com/reverse?ifp=foaf:mbox&path=mailto:"+url;

 Model model = ModelFactory.createDefaultModel();
 model.read(qdosLookup); 

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

Get the user's contacts from their foaf file. It only returns the url,
mboxsha1s or email at the moment, and the mboxsha1s are not normalised to the
google social graph sgns.

Nor do we yet include any other info (like name) for the user's friends,
though it'd be simple to do.

*/


public QdosUser getContacts(String url) throws java.io.IOException{

 try{

 String qdosLookup="http://foaf.qdos.com/reverse?";

 if(url.indexOf("@")!=-1){
  qdosLookup=qdosLookup+"ifp=foaf:mbox&path=mailto:"+url;
 }else if(url.indexOf("http")!=-1){
  qdosLookup=qdosLookup+"ifp=foaf:homepage&path="+url;
 }else{
 //assume mboxsha1sum
  qdosLookup=qdosLookup+"ifp=foaf:mbox_sha1sum&path="+url;
 }

 Model model = ModelFactory.createDefaultModel();
 model.read(qdosLookup); 

 String queryString = 
  "PREFIX foaf:   <http://xmlns.com/foaf/0.1/> "+
  "select distinct ?fn ?weblog ?homepage ?mbox ?mboxsha1 where { "+
  "?y foaf:knows ?x . "+
  "optional {?y foaf:name ?fn}. "+
  "optional {?y foaf:mbox ?mbox}. "+
  "optional {?y foaf:weblog ?weblog}. "+
  "optional {?y foaf:homepage ?homepage}. "+
  "optional {?y foaf:mbox_sha1sum ?mboxsha1}.} ";

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
//    System.out.println("S "+s+" r "+r);
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
