require 'pp'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/admin_reports_v1'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

scope = 'https://www.googleapis.com/auth/admin.reports.audit.readonly'

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

Reports = Google::Apis::AdminReportsV1
reports = Reports::ReportsService.new
reports.authorization = credentials

page_token = nil

loop do
  res = reports.list_activities(email, "drive", max_results: 1000, page_token: page_token)
  break if res.items.nil?

  res.items.each do |item|
    item.events.each do |event|
      p_doc_type = event.parameters.find{|p| p.name == "doc_type"}.value
      p_doc_id = event.parameters.find{|p| p.name == "doc_id"}.value
      p_doc_title = event.parameters.find{|p| p.name == "doc_title"}.value

      puts "#{item.id.time}\t#{item.actor.email}\t#{event.name}\t#{p_doc_type}\t#{p_doc_id}\t#{p_doc_title}"
    end

  end

  page_token = res.next_page_token

  if page_token.nil?
    break
  end
end
