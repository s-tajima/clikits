require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

file_id = ARGV.shift
permission_id = ARGV.shift

scope = 'https://www.googleapis.com/auth/drive'

client_id = Google::Auth::ClientId.from_file('client_secret.json')

token_store_file = 'credentials.yaml'
token_store = Google::Auth::Stores::FileTokenStore.new(file: token_store_file)

authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)

credentials = authorizer.get_credentials('default')
if credentials.nil?
  url = authorizer.get_authorization_url(base_url: OOB_URI)
  puts "Open #{url} in your browser and enter the resulting code."
  print "Code: "
  code = gets
  credentials = authorizer.get_and_store_credentials_from_code(user_id: 'default', code: code, base_url: OOB_URI)
end

Drive = Google::Apis::DriveV3
drive = Drive::DriveService.new
drive.authorization = credentials

begin
  drive.delete_permission(file_id, permission_id)
  puts "#{permission_id} for #{file_id} has been deleted."
rescue Google::Apis::ClientError => e
  puts "#{permission_id} for #{file_id} has NOT been deleted. (#{e.message})"
end
