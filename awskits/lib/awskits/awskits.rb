require 'aws-sdk'
require 'aws_config'
require 'pp'

module AWSKits
  class Factory
    def initialize(credential_file, role_arn)
      credentials = Aws::SharedCredentials.new(path: credential_file)
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

    def client(service, region='ap-northeast-1')
      Object.const_get("Aws::#{service}::Client").new(credentials: @credentials, region: region)
    end

    def resource(service)
      Object.const_get("Aws::#{service}::Resource").new(credentials: @credentials, region: region)
    end
  end
end
