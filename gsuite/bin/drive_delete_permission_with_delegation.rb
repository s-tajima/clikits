require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

file_id = ARGV.shift
permission_id = ARGV.shift
sub = ARGV.shift

scope = 'https://www.googleapis.com/auth/drive'

cred_file = 'credentials.json'
authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open(cred_file),
  scope: scope
)
authorizer.sub = sub
authorizer.fetch_access_token!

Drive = Google::Apis::DriveV3
drive = Drive::DriveService.new
drive.authorization = authorizer

begin
  drive.delete_permission(file_id, permission_id)
  puts "#{permission_id} for #{file_id} has been deleted."
rescue Google::Apis::ClientError => e
  puts "#{permission_id} for #{file_id} has NOT been deleted. (#{e.message})"
end
