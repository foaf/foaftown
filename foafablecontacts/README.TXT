This directory contains some tests for converting Portable Contacts into 
FOAF, and in doing so, exploring some extensions to FOAF to better cover
contacts data in a PC-friendly way.

Work in progress.

Dan <http://danbri.org/>




Airbag:grddl danbri$ xsltproc pc2foaf.xsl port-test.xml | rapper - file:


notes for foaf

 ---add a 'value' property?



if the values of 'tel', 'complex_name" (full_name) have URIs as values,
the type=home etc properties need to be objective.

A number is not intrinsically home, work etc., necessarily.

<Agent>
 <tel> 
  <PhoneAccount>
   <value>+1234</value>
   <type>CELL</type>
   <type>pref</type>
  </PhoneAccount>
 </tel>
</Agent> 

<Agent>
 <tel> 
  <PhoneAccount>
   <value>+4321</value>
   <type>CELL</type>
  </PhoneAccount>
 </tel>
</Agent> 
