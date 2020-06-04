def gen_client(api_key)
  Slack.configure do |c|
    c.token = api_key
  end

  Slack::Web::Client.new
end


def ids_to_emails(ids, users)
  emails = []
  ids.each do |id|
    user = users.detect{|u| u.id == id}

    if user.nil?
      emails << "N/A"
      next
    end
    
    emails << user.profile.email
  end
  emails
end

def emails_to_users(emails, users)
  res = []
  emails.each do |email|
    user = users.detect{|u| u.profile.email == email}

    if user.nil?
      puts "user #{email} is not exists."
      next
    end
    
    res << user.clone
  end
  res
end
