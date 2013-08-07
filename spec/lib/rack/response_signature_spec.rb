require 'spec_helper'

require 'rack/lint'
require 'rack/mock'

describe Rack::ResponseSignature do
  context 'response header' do
    it 'is added on a 200 response' do
      app = success_app("Success")
      expect(response_headers(app)).to have_key('X-Response-Signature')
    end

    it 'is not added on non-200 responses' do
      [ 302 , 404 , 503 ].each do |response_code|
        app = new_app(response_code, response_code.to_s)
        expect(response_headers(app)).not_to have_key('X-Response-Signature')
      end
    end
  end

  it 'does not modify the response body' do
    body = [" Whitespace "]
    app = new_app(200, body)
    expect(response_body(app)).to equal(body)
  end

  it 'ignores leading and trailing whitespace when generating signature' do
    expect(response_headers(success_app('test string'))).
      to include({'X-Response-Signature' => 't4IMaguaZTUFQ9LtPm7E4ijhVJ53OPe9a7wBujteaHQvHuacYgdSteQVTzxn%0AC%2BGoH8%2BdefNSTJa4fKl0PDXVUA%3D%3D%0A'})
    expect(response_headers(success_app(' test string'))).
      to include({'X-Response-Signature' => 't4IMaguaZTUFQ9LtPm7E4ijhVJ53OPe9a7wBujteaHQvHuacYgdSteQVTzxn%0AC%2BGoH8%2BdefNSTJa4fKl0PDXVUA%3D%3D%0A'})
    expect(response_headers(success_app('test string '))).
      to include({'X-Response-Signature' => 't4IMaguaZTUFQ9LtPm7E4ijhVJ53OPe9a7wBujteaHQvHuacYgdSteQVTzxn%0AC%2BGoH8%2BdefNSTJa4fKl0PDXVUA%3D%3D%0A'})
  end


  private


  def new_app(response_code, response_body)
    ->(env) { [response_code, {"Content-Type" => "test/plain"}, response_body] }
  end

  def private_key
    @private_key ||= <<-KEY.gsub(/^\s+/, '')
    -----BEGIN RSA PRIVATE KEY-----
    MIIBOgIBAAJBAMtIiebDa7r1Y+dD/avJpYAqkLMUwoRCrQSIdnG7LA1hFc9/r5JR
    jEtUSLA+eg0Fh72enu9+CT/q3Q4sg9h5s3UCAwEAAQJACAif2ozSjxrvjc40Ejvv
    3HbSLSGe5lc0Oz+hXrFE9mpTyFI7l/KYsMB/6JNEfY8LUNTQXz6fet4obIh9STIj
    6QIhAOVbthtvJK28o5V76ssZ8BkkYWQS9IUCxFXKIzbzJ3NHAiEA4uV0MBd+QHme
    QAviG5f/ZxlTQGQMtOtYaiNUCuaQaWMCIDjc2/FBRN6t/gB5kGR6McSJ+HtPF8BC
    R1rdmo1tC0LRAiBI7CPufO53vF6vCOKvqadNNGd8T2uCDg2JdzdAlZ+eLwIhALud
    aKQMQPo8Ie44nsCIT2FzI4YaNf1RvF+8E8FRXZBJ
    -----END RSA PRIVATE KEY-----
    KEY
  end

  def public_key
    @public_key ||= <<-KEY.gsub(/^\s+/, '')
    -----BEGIN PUBLIC KEY-----
    MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMtIiebDa7r1Y+dD/avJpYAqkLMUwoRC
    rQSIdnG7LA1hFc9/r5JRjEtUSLA+eg0Fh72enu9+CT/q3Q4sg9h5s3UCAwEAAQ==
    -----END PUBLIC KEY-----
    KEY
  end

  def request
    Rack::MockRequest.env_for
  end

  def response(app, *args)
    Rack::Lint.new(described_class.new(app, private_key, *args)).call(request)
  end

  def response_headers(app, *args)
    response(app, *args)[1]
  end

  def response_body(app, *args)
    response(app, *args)[2].instance_variable_get("@body")
  end

  def success_app(body_content)
    new_app(200, [body_content])
  end
end
