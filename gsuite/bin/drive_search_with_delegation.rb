require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

email = ARGV.shift
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

query = "'#{email}' in owners or '#{email}' in writers or '#{email}' in readers"
fields = 'files(id, name, permissions(id, type, role, emailAddress, domain)), nextPageToken'
page_token = ''

loop do
  res = drive.list_files(q: query, fields: fields, page_token: page_token)
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
