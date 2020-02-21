require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

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

email = ARGV.shift

query = "'#{email}' in owners or '#{email}' in writers or '#{email}' in readers"
fields = 'files(id, name, permissions(id, type, role, emailAddress, domain))'
page_token = nil

loop do
  res = drive.list_files(q: query, fields: fields, page_size: 1000, page_token: page_token)

  res.files.each do |file|
    unless file.permissions.nil?
      perm = file.permissions.select{|p| p.email_address == email }.first
      perm_id = perm.id
      perm_role = perm.role
    end
    puts "#{file.id}\t#{perm_id}\t#{perm_role}\t#{file.kind}\t#{file.name}"
  end

  page_token = res.next_page_token

  if page_token.nil?
    break
  end
end
