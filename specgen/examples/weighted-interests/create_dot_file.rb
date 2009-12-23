require 'rubygems'
require 'uri'
require 'open-uri'
require 'net/http'
require 'hpricot'
require 'digest/sha1'
require 'reddy'

def createDotFile(graph)
  #hmmm would be cool
  #loop through all, getting out types
  # if not a type make a link
  nodes = {}
  links = []
  count = 0
  text = "digraph Summary_Graph {\nratio=0.7\n"
  graph.triples.each do |t|
    if nodes.include?(t.object.to_s)
      n = nodes[t.object.to_s]
    else
      n = "n#{count}"
      nodes[t.object.to_s]=n
      count=count+1
    end

    if nodes.include?(t.subject.to_s)
      n2 = nodes[t.subject.to_s]
    else
      n2 = "n#{count}"
      nodes[t.subject.to_s]=n2
      count=count+1
    end

    if t.predicate.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
      else
       r = t.predicate.to_s
       if (r =~ /.*\/(.*)/ )
          r = $1
       end
       if (r =~ /.*#(.*)/ )
          r = $1
       end
       links.push("#{n2}->#{n} [label=\"#{r}\"]")
    end
  end
  #puts nodes

  nodes.each_key do |k|
     r = k.to_s
     if (r =~ /.*\/(.*)/ )
        r = $1
     end
     if (r =~ /.*#(.*)/ )
        r = $1
     end
     text << "#{nodes[k]} [label=\"#{r}\"]\n"
  end
  text << links.join("\n")
  text << "\n}"
  #puts text
  file = File.new("test.dot", "w")
  file.puts(text)
end


def createDotFileFromSchema(graph, xmlns_hash)
  #puts xmlns_hash
  #use domain and range to create links

  nodes = {}
  links = []
  count = 0
  text = "digraph Summary_Graph {\nratio=0.7\n"
  graph.triples.each do |t|

##object properties

    if t.predicate.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" && t.object.to_s == "http://www.w3.org/2002/07/owl#ObjectProperty"
      s = t.subject
      #dd = graph.each_with_subject(s)
      #puts "S: "+s.to_s+"\n"

      ss = s.to_s

      ns = ""
      if (ss =~ /(http.*)#(.*)/ )
         ns = $1+"#"
         ss = $2
      else
        if (ss =~ /(http.*)\/(.*)/ )
           ns = $1+"/"
           ss = $2
        end
      end

      nssm=""
      #puts "NS "+ns
      if ns && ns!=""
         nssm = xmlns_hash[ns]
      end
      foo = nssm.gsub(/xmlns:/,"")
      ss=foo+":"+ss

      dom=""
      ran=""

      graph.triples.each do |tt|
        if tt.subject.to_s==s.to_s && tt.predicate.to_s=="http://www.w3.org/2000/01/rdf-schema#domain"

           ns = ""
           dom = tt.object.to_s
           if (dom =~ /(http.*)#(.*)/ )
             ns = $1+"#"
             dom = $2
           else
             if (dom =~ /(http.*)\/(.*)/ )
               ns = $1+"/"
               dom = $2
             end
           end

           nssm=""
           if ns && ns!=""
             nssm = xmlns_hash[ns]
           end
           foo = nssm.gsub(/xmlns:/,"")
           dom=foo+":"+dom

           if nodes.include?(dom)
           else
             nodes[dom]=dom
           end
           #print "domain: "+tt.object.to_s+"\n"
        end
        if tt.subject.to_s==s.to_s && tt.predicate.to_s=="http://www.w3.org/2000/01/rdf-schema#range"

           ns = ""
           ran = tt.object.to_s
           if (ran =~ /(http.*)#(.*)/ )
             ns = $1+"#"
             ran = $2
           else
             if (ran =~ /(http.*)\/(.*)/ )
               ns = $1+"/"
               ran = $2
             end
           end

           nssm=""
           if ns && ns!=""
             nssm = xmlns_hash[ns]
           end
           foo = nssm.gsub(/xmlns:/,"")
           ran=foo+":"+ran

           links.push("\"#{dom}\"->\"#{ran}\" [label=\"#{ss}\"]")

           if nodes.include?(ran)
           else
             nodes[ran]=ran
           end

           #print "range: "+tt.object.to_s+"\n"
        end
      end
    end

#datatype properties


    if t.predicate.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" && t.object.to_s == "http://www.w3.org/2002/07/owl#DatatypeProperty"
      s = t.subject
      #dd = graph.each_with_subject(s)
      #puts "S: "+s.to_s+"\n"
      ss = s.to_s

      ns = ""
      if (ss =~ /(http.*)#(.*)/ )
         ns = $1+"#"
         ss = $2
      else
        if (ss =~ /(http.*)\/(.*)/ )
           ns = $1+"/"
           ss = $2
        end
      end

      nssm=""
      #puts "NS "+ns
      if ns && ns!=""
         nssm = xmlns_hash[ns]
      end
      foo = nssm.gsub(/xmlns:/,"")
      ss=foo+":"+ss

      dom=""
      ran=""
      graph.triples.each do |tt|
        if tt.subject.to_s==s.to_s && tt.predicate.to_s=="http://www.w3.org/2000/01/rdf-schema#domain"
           ns = ""
           dom = tt.object.to_s
           if (dom =~ /(http.*)#(.*)/ )
             ns = $1+"#"
             dom = $2
           else
             if (dom =~ /(http.*)\/(.*)/ )
               ns = $1+"/"
               dom = $2
             end
           end

           nssm=""
           if ns && ns!=""
             nssm = xmlns_hash[ns]
           end
           foo = nssm.gsub(/xmlns:/,"")
           dom=foo+":"+dom

           if nodes.include?(dom)
           else
             nodes[dom]=dom
           end
           #print "domain: "+tt.object.to_s+"\n"
        end
        if tt.subject.to_s==s.to_s && tt.predicate.to_s=="http://www.w3.org/2000/01/rdf-schema#range"

           ns = ""
           ran = tt.object.to_s
           if (ran =~ /(http.*)#(.*)/ )
             ns = $1+"#"
             ran = $2
           else
             if (ran =~ /(http.*)\/(.*)/ )
               ns = $1+"/"
               ran = $2
             end
           end

           nssm=""
           if ns && ns!=""
             nssm = xmlns_hash[ns]
           end
           foo = nssm.gsub(/xmlns:/,"")
           ran=foo+":"+ran


           links.push("\"#{dom}\"->\"#{ran}\" [label=\"#{ss}\"]")

           if nodes.include?(ran)
           else
             nodes[ran]=ran
           end
           #print "range: "+tt.object.to_s+"\n"
        end
      end
    end

# note - just handle unionOf, parsetype=collection etc

# any remaining classes

    if t.predicate.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" && (t.object.to_s=="http://www.w3.org/2000/01/rdf-schema#Class" || t.object.to_s=="http://www.w3.org/2002/07/owl#Class")
      s = t.subject
      puts "S: "+s.to_s+"\n"

      ss = s.to_s

      ns = ""
      if (ss =~ /(http.*)#(.*)/ )
         ns = $1+"#"
         ss = $2
      else
        if (ss =~ /(http.*)\/(.*)/ )
           ns = $1+"/"
           ss = $2
        end
      end

      nssm=""
      #puts "NS "+ns
      if ns && ns!=""
         nssm = xmlns_hash[ns]
      end
      foo = nssm.gsub(/xmlns:/,"")
      ss=foo+":"+ss

      if nodes.include?(ss)
      else
        nodes[ss]=ss
      end
   end

  end


  nodes.each_key do |k|
     text << "\"#{nodes[k]}\" [label=\"#{k}\"]\n"
  end
  text << links.join("\n")
  text << "\n}"
  #puts text
  file = File.new("test_schema.dot", "w")
  file.puts(text)

end


    
def has_object(graph,object)
  graph.triples.each do |value|
    if value.object == object
      return true
    end
  end
  return false
end

def each_with_object(graph, object)
  graph.triples.each do |value|
    yield value if value.object == object
  end
end


begin
 #load rdfxml file
 doc = File.read("index.rdf")
 parser = RdfXmlParser.new(doc)

 xml = Hpricot.XML(doc)
 xmlns_hash = {}
 (xml/'rdf:RDF').each do |item|
   h = item.attributes
   h.each do |xmlns|
     short = xmlns[0]
     uri = xmlns[1]
     xmlns_hash[uri]=short
     parser.graph.namespace(uri, short)
   end
 end


 puts parser.graph.to_ntriples
# createDotFile(parser.graph)
 createDotFileFromSchema(parser.graph, xmlns_hash)

end

