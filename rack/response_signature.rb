require 'openssl'
require 'base64'
require 'cgi'

module Rack
  
  ##
  # Rack::ResponseSignature is a middleware which will manipulate the server
  # response by signing the response body against an RSA private key.  Your 
  # clients may then validate the response against a known-good public key
  # to verify server authenticity against a man-in-the-middle attack.
  # 
  # The signature, if generated, is placed in a "Response-Signature" HTTP 
  # header.  Currently, signatures are only generated for HTTP SUCCESS (200) 
  # responses.
  # 
  # Obviously, it would be more straightforward to simply use an SSL 
  # certificate provided by a trusted CA and just enable SSL verification
  # per request.  However, the use of SSL acrues significate overhead both for
  # the server, the client, and the network in general.  Not only that, but
  # in some cases (like Heroku) using a custom, verifiable SSL certificate
  # is either not a reasonable or not possible.
  # 
  # === Using Rack::ResponseSignature
  # 
  # To use this middleware, simply:
  # 
  #     use Rack::ResponseSignature, "--- BEGIN PRIVATE KEY ----\nabc123....."
  # 
  # Or, for Rails,
  # 
  #     config.middleware.use "Rack::ResponseSignature", "--- BEGIN PRIVATE KEY ----\nabc123....."
  # 
  # Or, a somewhat more secure approach would be to utilize environment 
  # variables on the production system to define your private key.  This 
  # keeps your private keys out of your source code manager and away from
  # prying eyes:
  # 
  #     config.middleware.use "Rack::ResponseSignature", ENV['PRIVATE_RESPONSE_KEY']
  # 
  # This is especially useful for Heroku deployments.
  # 
  # === Manual Verification of Signature
  # 
  # Using curl, you can manually inspect to be sure that your signatures are 
  # being generated with:
  # 
  #     $ curl -is http://myserver.com
  # 
  # Which would return something similar to:
  # 
  #     HTTP/1.1 200 OK
  #     Server: nginx/0.6.39
  #     Date: Tue, 23 Feb 2010 05:15:25 GMT
  #     Content-Type: application/xml; charset=utf-8
  #     Transfer-Encoding: chunked
  #     Connection: keep-alive
  #     ETag: "54a2096d2c361907b3f9cc7ec9a2231d"
  #     Response-Signature: JywymlJfA90Q4x52LKt4J8Tb8p4rXI%2BptKDNm3NC7F495...
  #     Cache-Control: private, max-age=0, must-revalidate
  # 
  # === Client Verification
  # 
  # To verify your signatures on the client, simply share your public RSA key
  # with your client and verify the response:
  # 
  #     require 'net/http'
  #     require 'base64'
  #     require 'cgi'
  #     
  #     uri = URI.parse("http://myserver.com/")
  #     response = nil
  #     Net::HTTP.start(uri.host, uri.port) do |http|
  #       response = http.get(uri.path)
  #     end
  #     
  #     puts "Response valid? %s" % [OpenSSL::PKey::RSA.new(PublicKey).
  #       verify(OpenSSL::Digest::SHA256.new, 
  #             Base64.decode64(CGI.unescape(response['Response-Signature'])), 
  #             response.body.strip)]
  # 
  # === Options
  # 
  # You may pass an optional, third, hash argument into the middleware.  This
  # argument allows you to override defaults.
  # 
  # digest::
  #   Set the digest to use when generating the signature (Default: OpenSSL::Digest::SHA256)
  # 
  class ResponseSignature
    
    def initialize(app, private_key, options = {})
      options[:digest]  ||= OpenSSL::Digest::SHA256
      @app              = app
      @private_key      = private_key && private_key != '' ? private_key : nil
      @options          = options
    end
    
    def call(env)
      status, headers, response = @app.call(env)
      
      if set_signature_header?(status)
        [status, add_signature(headers, value_of(response)), value_of(response)]
      else
        [status, headers, response]
      end
    end
    
    
    private
    
    
    def set_signature_header?(status)
      @private_key && status.to_i == 200
    end
    
    def add_signature(headers, body)
      headers['Response-Signature'] = CGI.escape(Base64.encode64(sign(body)))
      headers
    end
    
    def rsa
      @rsa ||= OpenSSL::PKey::RSA.new(@private_key)
    end
    
    def sign(data)
      rsa.sign(digest, data)
    end
    
    def digest
      @options.has_key?(:digest) ? @options[:digest].new : OpenSSL::Digest::SHA256.new
    end
    
    def value_of(response)
      (response.respond_to?(:body) ? response.body : response).strip
    end
    
  end
  
end
