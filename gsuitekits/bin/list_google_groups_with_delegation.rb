require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/admin_directory_v1'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
CLIENT_SECRET_PATH = 'service_account_client_secret.json'

scope = [
  'https://www.googleapis.com/auth/admin.directory.group',
  'https://www.googleapis.com/auth/admin.directory.user'
]

sub = ARGV.shift

authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open(CLIENT_SECRET_PATH),
  scope: scope
)
authorizer.sub = sub
authorizer.fetch_access_token!

service = Google::Apis::AdminDirectoryV1::DirectoryService.new
service.authorization = authorizer

groups = service.list_groups(customer: 'my_customer').groups

groups.each do |group|
  members = service.list_members(group.email).members

  next if members.nil?

  members.each do |member|
    puts "#{group.id}\t#{group.name}\t#{group.email}\t#{member.email}\t#{member.type}"
  end
end
