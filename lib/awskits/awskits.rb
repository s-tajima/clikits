require 'aws-sdk'
require 'aws_config'
require 'pp'

module AWSKits
  class Factory
    def initialize(profile, token_code)
      role_arn       = AWSConfig[profile].role_arn
      source_profile = AWSConfig[profile].source_profile.name
      mfa_serial     = AWSConfig[profile].mfa_serial
      
      credentials = Aws::SharedCredentials.new(profile_name: source_profile)
      sts = Aws::STS::Client.new(credentials: credentials)
      
      resp = sts.get_session_token({
        duration_seconds: 900, 
        serial_number: mfa_serial,
        token_code: token_code
      })
      
      credentials = Aws::Credentials.new(
        resp.credentials.access_key_id,
        resp.credentials.secret_access_key, 
        resp.credentials.session_token
      )
      sts = Aws::STS::Client.new(credentials: credentials)
      
      resp = sts.assume_role({
        duration_seconds: 900, 
        role_arn: role_arn,
        role_session_name: "awskit", 
      })

      @credentials = Aws::Credentials.new(
        resp.credentials.access_key_id,
        resp.credentials.secret_access_key, 
        resp.credentials.session_token
      )
    end

    def client(service)
      Object.const_get("Aws::#{service}::Client").new(credentials: @credentials)
    end

    def resource(service)
      Object.const_get("Aws::#{service}::Resource").new(credentials: @credentials)
    end
  end
end
