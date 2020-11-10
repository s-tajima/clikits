require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/admin_directory_v1'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

scope = 'https://www.googleapis.com/auth/admin.directory.group.readonly'

email = ARGV.shift

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

service = Google::Apis::AdminDirectoryV1::DirectoryService.new
service.authorization = credentials

groups = service.list_groups(customer: 'my_customer').groups

groups.each do |group|
  members = service.list_members(group.email).members
  members.each do |member|
    puts "#{group.id}\t#{group.name}\t#{group.email}\t#{member.email}\t#{member.type}"
  end
end

