require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

domains = ARGV

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
  code = $stdin.gets
  credentials = authorizer.get_and_store_credentials_from_code(user_id: 'default', code: code, base_url: OOB_URI)
end

Drive = Google::Apis::DriveV3
drive = Drive::DriveService.new
drive.authorization = credentials

fields = 'files(id, name, permissions(id, type, role, emailAddress, domain)), nextPageToken'
page_token = nil

loop do
  warn "token: #{page_token}"
  res = drive.list_files(fields: fields, page_size: 1000, page_token: page_token)

  res.files.each do |file|
    next if file.permissions.nil?

    file.permissions.each do |perm|
      next if perm.type == 'domain'

      if perm.type == 'user' || perm.type == 'group'
        domain = perm.email_address.split("@")[-1]
        next if domains.include?(domain)
        puts "#{file.id}\t#{file.name}\t#{perm.type}\t#{domain}\t#{perm.email_address}\t#{perm.role}\t#{perm.id}"
        next
      end

      if perm.type == 'anyone'
        puts "#{file.id}\t#{file.name}\t#{perm.type}\tanyone\t#{perm.role}\t#{perm.id}"
        next
      end

      pp perm
      exit
    end
  end

  page_token = res.next_page_token

  if page_token.nil?
    break
  end
end
