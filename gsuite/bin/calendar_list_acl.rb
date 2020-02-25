require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/calendar_v3'
require 'google/apis/admin_directory_v1'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

domain = ARGV.shift

scopes = [
  'https://www.googleapis.com/auth/calendar',
  'https://www.googleapis.com/auth/admin.directory.user.readonly'
]

client_id = Google::Auth::ClientId.from_file('client_secret.json')

token_store_file = 'credentials.yaml'
token_store = Google::Auth::Stores::FileTokenStore.new(file: token_store_file)

authorizer = Google::Auth::UserAuthorizer.new(client_id, scopes, token_store)

credentials = authorizer.get_credentials('default')
if credentials.nil?
  url = authorizer.get_authorization_url(base_url: OOB_URI)
  puts "Open #{url} in your browser and enter the resulting code."
  print "Code: "
  code = gets
  credentials = authorizer.get_and_store_credentials_from_code(user_id: 'default', code: code, base_url: OOB_URI)
end

Directory = Google::Apis::AdminDirectoryV1
directory = Directory::DirectoryService.new
directory.authorization = credentials

Calendar = Google::Apis::CalendarV3
calendar = Calendar::CalendarService.new
calendar.authorization = credentials

res = directory.list_users(domain: domain)

res.users.each do |user|
  begin
    res_acls = calendar.list_acls(user.primary_email)
  rescue Google::Apis::ClientError => e
    puts "#{user.primary_email} error (#{e.message})"
    next
  end

  res_acls.items.each do |item|
    puts "#{user.primary_email}\t#{item.role}\t#{item.id}"
  end
end
