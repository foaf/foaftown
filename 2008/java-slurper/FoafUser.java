import java.io.*;
import java.util.*;
import com.hp.hpl.jena.rdf.model.*;
import com.hp.hpl.jena.query.*;

public class FoafUser{

/**

Main method demonstrating getDetails and getContacts.

*/


public static void main(String[] args){

 String lookup="danbri.org";
 if(args.length > 0){
  lookup=args[0];
 }

 try{
  FoafUser u = new FoafUser();
  u.getDetails(lookup);
  System.out.println("Attributes: "+u.getAttributes());
  u.getContacts(lookup);
  System.out.println("Contacts: "+u.getContactsReferenced());

 }catch(Exception e){
  System.out.println("problem "+e);
 }
}

/**

Internal objects that get filled and returned.

*/

Map attributes=new HashMap();
List contactsReferenced=new ArrayList();

/**

Get methods for the useful Objects.

*/

 public Map getAttributes(){
  return this.attributes;
 }
 
 public List getContactsReferenced(){
  return this.contactsReferenced;
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

Get the user's contacts from their foaf file. It only returns the url,
mboxsha1s or email at the moment, and the mboxsha1s are not normalised to the
google social graph sgns.

Nor do we yet include any other info (like name) for the user's friends,
though it'd be simple to do.

*/


public FoafUser getContacts(String url) throws java.io.IOException{

 try{

 Model model = ModelFactory.createDefaultModel();
 model.read(url); 

 String queryString = 
  "PREFIX foaf:   <http://xmlns.com/foaf/0.1/> "+
  "select distinct ?fn ?weblog ?homepage ?mbox ?mboxsha1 where { "+
  "?x foaf:knows ?y . "+
//  "optional {?y foaf:name ?fn}. "+
  "optional {?y foaf:weblog ?weblog}. "+
  "optional {?y foaf:homepage ?homepage}. "+
  "optional {?y foaf:mbox_sha1sum ?mboxsha1}. "+
  "optional {?y foaf:mbox ?mbox}.} ";

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
      contactsReferenced.add(r);
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

}
