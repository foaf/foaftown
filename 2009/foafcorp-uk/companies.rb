require 'rubygems'
require 'net/http'
require 'uri'
require 'open-uri'
require 'digest/md5'


class Data

   def Data.post(u,data)
       begin
         puts "Checking url #{u}"
         url = URI.parse u
         http = Net::HTTP.new(url.host, url.port)
         res, body = http.post(url.path, data,
{'Content-type'=>'text/xml;charset=utf-8'})         
         case res
         when Net::HTTPSuccess, Net::HTTPRedirection
           puts "response #{res.body}"
         else
           puts "problem"
         end
       rescue URI::InvalidURIError
         puts "URI is no good"
       end
   end


   def Data.searchForCompany(companyName)

   user = "XMLGatewayTestUser"
   pass = "XMLGatewayTestPass"
   transactionId = rand(7)

   digest = Digest::MD5.hexdigest("#{user}#{pass}#{transactionId}")

doc="
<GovTalkMessage xmlns=\"http://www.govtalk.gov.uk/schemas/govtalk/govtalkheader\"
                xmlns:dsig=\"http://www.w3.org/2000/09/xmldsig#\" 
                xmlns:gt=\"http://www.govtalk.gov.uk/schemas/govtalk/core\" 
                xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" 
                xsi:schemaLocation=\"http://www.govtalk.gov.uk/schemas/govtalk/govtalkheader\">
  <EnvelopeVersion>1.0</EnvelopeVersion>
  <Header>
    <MessageDetails>
      <Class>NameSearch</Class>
      <Qualifier>request</Qualifier>
      <TransactionID>#{transactionId}</TransactionID>
    </MessageDetails>
    <SenderDetails>
      <IDAuthentication>
        <SenderID>#{user}</SenderID>
        <Authentication>
          <Method>CHMD5</Method>
          <Value>#{digest}</Value>
        </Authentication>
      </IDAuthentication>
      <EmailAddress>libby@nicecupoftea.org</EmailAddress>
    </SenderDetails>
  </Header>
  <GovTalkDetails>
    <Keys/>
  </GovTalkDetails>
  <Body>
    <NameSearchRequest xmlns=\"http://xmlgw.companieshouse.gov.uk/v1-0\" 
                           xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                           xsi:schemaLocation=\"http://xmlgw.companieshouse.gov.uk/v1-0/schema/NameSearch.xsd\">
      <CompanyName>#{companyName}</CompanyName>
      <DataSet>LIVE</DataSet>
      <SearchRows>20</SearchRows>
    </NameSearchRequest>
  </Body>
</GovTalkMessage>"


  return doc

  end


   def Data.getCompanyDetails(companyNumber)

   user = "XMLGatewayTestUserID"
   pass = "XMLGatewayTestPassword"
   transactionId = rand(7)

   digest = Digest::MD5.hexdigest("#{user}#{pass}#{transactionId}")

doc="
<GovTalkMessage xmlns=\"http://www.govtalk.gov.uk/schemas/govtalk/govtalkheader\"
                xmlns:dsig=\"http://www.w3.org/2000/09/xmldsig#\" 
                xmlns:gt=\"http://www.govtalk.gov.uk/schemas/govtalk/core\" 
                xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" 
                xsi:schemaLocation=\"http://www.govtalk.gov.uk/schemas/govtalk/govtalkheader\">
  <EnvelopeVersion>1.0</EnvelopeVersion>
  <Header>
    <MessageDetails>
      <Class>CompanyDetails</Class>
      <Qualifier>request</Qualifier>
      <TransactionID>#{transactionId}</TransactionID>
    </MessageDetails>
    <SenderDetails>
      <IDAuthentication>
        <SenderID>#{user}</SenderID>
        <Authentication>
          <Method>CHMD5</Method>
          <Value>#{digest}</Value>
        </Authentication>
      </IDAuthentication>
      <EmailAddress>libby@nicecupoftea.org</EmailAddress>
    </SenderDetails>
  </Header>
  <GovTalkDetails>
    <Keys/>
  </GovTalkDetails>
  <Body>
    <CompanyDetailsRequest xmlns=\"http://xmlgw.companieshouse.gov.uk/v1-0\" 
                           xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                           xsi:schemaLocation=\"http://xmlgw.companieshouse.gov.uk/v1-0/CompanyDetails.xsd\">
      <CompanyNumber>#{companyNumber}</CompanyNumber>
      <GiveMortTotals>1</GiveMortTotals>
    </CompanyDetailsRequest>
  </Body>
</GovTalkMessage>"


  return doc

  end




   def Data.getCompanyAppointments(companyNumber, companyName)

   user = "XMLGatewayTestUserID"
   pass = "XMLGatewayTestPassword"
   transactionId = rand(7)

   digest = Digest::MD5.hexdigest("#{user}#{pass}#{transactionId}")

doc="
<GovTalkMessage xmlns=\"http://www.govtalk.gov.uk/schemas/govtalk/govtalkheader\"
                xmlns:dsig=\"http://www.w3.org/2000/09/xmldsig#\" 
                xmlns:gt=\"http://www.govtalk.gov.uk/schemas/govtalk/core\" 
                xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" 
                xsi:schemaLocation=\"http://www.govtalk.gov.uk/schemas/govtalk/govtalkheader\">
  <EnvelopeVersion>1.0</EnvelopeVersion>
  <Header>
    <MessageDetails>
      <Class>CompanyAppointments</Class>
      <Qualifier>request</Qualifier>
      <TransactionID>#{transactionId}</TransactionID>
    </MessageDetails>
    <SenderDetails>
      <IDAuthentication>
        <SenderID>#{user}</SenderID>
        <Authentication>
          <Method>CHMD5</Method>
          <Value>#{digest}</Value>
        </Authentication>
      </IDAuthentication>
      <EmailAddress>libby@nicecupoftea.org</EmailAddress>
    </SenderDetails>
  </Header>
  <GovTalkDetails>
    <Keys/>
  </GovTalkDetails>
  <Body>
    <CompanyDetailsRequest xmlns=\"http://xmlgw.companieshouse.gov.uk/v1-0\" 
                           xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                           xsi:schemaLocation=\"http://xmlgw.companieshouse.gov.uk/v1-0/schema/CompanyAppointments.xsd\">
      <CompanyName>#{companyName}</CompanyName>
      <CompanyNumber>#{companyNumber}</CompanyNumber>
      <IncludeResignedInd>1</IncludeResignedInd>
    </CompanyDetailsRequest>
  </Body>
</GovTalkMessage>"


  return doc

  end


end


url = "http://xmlgw.companieshouse.gov.uk/v1-0/xmlgw/Gateway"
companyNumber="03176906"
companyName="MILLENNIUM STADIUM PLC"

## 3 different options
## uncomment the one you want

#xml = Data.searchForCompany("MILLENNIUM")
#xml = Data.getCompanyDetails(companyNumber)
xml = Data.getCompanyAppointments(companyNumber,companyName)

Data.post(url,xml)
