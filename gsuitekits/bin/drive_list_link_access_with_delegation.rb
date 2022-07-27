require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

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

query = "visibility = 'anyoneWithLink'"
fields = 'files(id, webViewLink, name, permissions(id, type, role, emailAddress, domain), owners), nextPageToken'
page_token = ''

loop do
  res = drive.list_files(q: query, fields: fields, page_token: page_token)
  res.files.each do |file|
    next if file.permissions.nil?

    file.permissions.each do |perm|
      next if perm.type == 'domain'
      next if file.name =~ /\.(png|jpeg|jpg|svg)$/

      if perm.type == 'anyone'
        puts "#{file.id}\t#{file.name}\t#{file.owners[0].email_address}\t#{perm.type}\tanyone\t#{perm.role}\t#{perm.id}\t#{file.web_view_link}"
        next
      end
    end
  end

  page_token = res.next_page_token

  if page_token.nil?
    break
  end
end
