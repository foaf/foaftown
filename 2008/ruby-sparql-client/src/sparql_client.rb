#!/usr/bin/ruby 

## python used: import urllib, urllib2

# copied from ivan's stuff and cut down massively

module SPARQL 

#  Possible output format keys...
JSON   = "json"
XML    = "xml"
TURTLE = "n3"
N3     = "n3"
ALLOWED_FORMATS = [JSON, XML, TURTLE, N3]

# note: I upcased ALLOWED FORMATS, also removed _ prefix from this and the 
# following, since _ counts as lowercase. --danbri

SPARQL_XML  = ["application/sparql-results+xml"]
SPARQL_JSON = ["application/sparql-results+json","text/javascript"]
RDF_XML     = ["application/rdf+xml"]
RDF_N3      = ["text/rdf+n3","application/n-triples","application/turtle","application/n3","text/n3"]

RETURNFORMATSETTING = ["output","results","format"] # ask Bengee/IVan about this
# was	_returnFormatSetting	

		
# Wrapper around an online access to a SPARQL entry point on the Web.

class SPARQLWrapper 

      attr_accessor :baseURI, :_querytext, :queryString, :returnFormat, :URI, :retval


        # Constructs a Class encapsulating a full SPARQL call.
		# @param baseURI: string of the SPARQL endpoint's URI
		# @type baseURI: string
		# @param returnFormat: the default is XML. 
		# Can be set to JSON or Turtle (but no local check is done, the parameter is simply 
		# sent to the endpoint. Eg, if the value is set to JSON and a construct query is issued, it 
		# is up to the endpoint to react or not, this wrapper does not check). Possible values: 
		# JSON, XML, TURTLE, N3 (constants in this module). The value can also be set via explicit 
		# call, see below. 
		# @type returnFormat: string
		# @param defaultGraph: URI for the default graph. Default is nil, can be set 
		# via an explicit call, too
		# @type defaultGraph: string
		
		
	def initialize(baseURI,returnFormat="XML",defaultGraph=nil) 
    	self.baseURI     = baseURI
		self._querytext  = []
		if defaultGraph 
		  self._querytext.push(["default-graph-uri", defaultGraph] )
        end

		self.queryString = """SELECT * WHERE{ ?s ?p ?o }"""
		
		if  ALLOWED_FORMATS.member? returnFormat
			self.returnFormat = returnFormat
	    else 
			self.returnFormat = XML	
        end

		self.retval = nil
		self.URI    = ""
    end			



	# Set the return format. If not an allowed value, the setting is ignored.
   	# 	
	# Note that not all endpoints implement all formats and some combinations may not work. 
	# For example, N3/TURTLE is understood by  some endpoints (eg, Joseki or Virtuoso) even 
	# in the case of a SELECT query (and a list is returned) but it is by no way a standard 
	# return format.
	# 
	# @param format: Possible values: are JSON, XML, TURTLE, N3 (constants in this module). 
	# N3 and TURTLE are synonyms.
	# @type format: string

	def setReturnFormat(format) 

		if ALLOWED_FORMATS.member? format
			self.returnFormat = format
        end
    end
      		

    # Add a default graph URI
    # @param uri: URI of the graph
    # @type uri: string

	def addDefaultGraph(uri) 

		if uri 
		  self._querytext.push(["default-graph-uri",uri])
		end
	end
		

    # Add a named graph URI
    # @param uri: URI of the graph
    # @type uri: string

	def addNamedGraph(uri) 
		
		if uri 
			self._querytext.push(["named-graph-uri",uri])
	    end
	end
	

    # Some SPARQL endpoints require extra key value pairs for out-of-band settings.
    # E.g., in virtuoso, one would add should-sponge=soft to the query to force virtuoso
    # to retrieve graphs that are not stored in its local database
	# These are added to the final query URI
	# @param key: key of the query part
	# @type key: string
	# @param value: value of the query part
	# @type value: string

	def addExtraURITag(key,value) 
		self._querytext.push([key,value])	
	end
	
	
	# Set the SPARQL query text. Note: no check is done on the query (syntax or otherwise) by this module!
	# @param query: query text
    # @type query: string

	def setQuery(query) 
		self.queryString = query
   end
   
	# Return the URI as sent (or to be sent) to the SPARQL endpoint. The URI is constructed 
	# with the base URI given at initialization, plus all the other parameters set.
	# @return: URI
	# @rtype: string

	def getURI()
		
		self._querytext.push(["query",self.queryString])
		if (self.returnFormat != XML) 
			# This is very ugly. The fact is that the key for the choice of the output format is not defined. Virtuoso uses 'format', 
			# sparqler uses 'output'
			# However, these processors are (hopefully) oblivious to the parameters they do not understand. So: just repeat all possibilities
			# in the final URI. UGLY!!!!!!!

### todo    for f in RETURNFORMATSETTING: self._querytext.push([f,self.returnFormat])
            RETURNFORMATSETTING.each do |f| 
              self._querytext.push([f,self.returnFormat])
            end
        end
        
        begin
          require 'cgi'
          #puts "Query text is: #{self._querytext}"
          esc = ""
          self._querytext.each do |a|
            # puts "#{a}"  
            esc += a[0] + "=" + CGI.escape(a[1]) +"&"
          end
          self.URI= self.baseURI + "?" + esc           
        rescue
          puts "Something bad with url escaping... #{$!} self.URI: #{self.URI}\n"
        end
		return self.URI
	end
	


    # Internal method to execute the query. Returns the output of the 
	# C{urllib2.urlopen} method of the
	# standard Python library
	# @return: query result


# todo, choose http lib
# http://felipec.wordpress.com/2007/06/01/more-ruby-vs-python/
# http://www.ruby-doc.org/stdlib/libdoc/open-uri/rdoc/index.html
	def _query() 

#		request = urllib2.Request(self.getURI())

        require "open-uri"

        res = ""        
        puts "Response from GET to #{self.getURI()} was: \n\n"
        open(self.getURI()) do |f|
          f.each_line do |line| 
            # p line
            res += line
          end
          puts "\n\n"
        end

		# Some versions of Joseki do not work well if no Accept header is given. Although it is probably o.k. in newer versions, 
		# it does not harm to have that set once and for all...
		# Also, joseki seems to work for the n3/turtle result only via an extra header and not the get URI...
		if (self.returnFormat == N3 or self.returnFormat == TURTLE )

# todo: figure out how to add header requests in ruby
#
#			request.add_header("Accept","application/n3")
#		else 
#			request.add_header("Accept","*/*")

        end

        return res # not just a string tho
#		return nil # todo urllib2.urlopen(request)
      
	end
	
		
    # Execute the query.
    # Exceptions can be raised if either the URI is wrong or the HTTP sends back an error.
    # The usual urllib2 exceptions are raised, which cover possible SPARQL errors, too.
    #		 	
    # The return is an instance of L{QueryResult}
    #						
    # Note that in the case of errors (eg, raised by the sparql processor), the 
    # rllib2 raises 
    # exceptions. Refer to the Python documentation on those.
    # @return: query result
    # @rtype: L{QueryResult} instance

	def query() 

        begin
  		    return QueryResult.new(self._query())
        rescue
            puts "Bad things returning query. #{$!} "
        end
	end
		
    # Macro like method: issue a query and return the converted results.
	# @return: the converted query result. See the conversion methods for more details.
	
	def queryAndConvert() 
		res = self.query()
		return res.convert()
    end

end

class QueryResult
  def initialize() 
    raise "Unimplemented."
  end
end


end
