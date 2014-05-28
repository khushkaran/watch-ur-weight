require 'json'
require 'rest_client'
require "user_file"

class Report
  def json(response)
    JSON.parse(response)
  end

  def list_files(username, password, apikey)
    response =  RestClient.post 'https://my.workshare.com/api/open-v1.0/user_sessions.json', "user_session[email]" => username, "user_session[password]" => password, "device[app_uid]" => apikey
    resource = RestClient::Resource.new("https://my.workshare.com/api/open-v1.0/files.json", :cookies => response.cookies)
    resource.get(:accept => 'application/json')
  end

  def extract_files(parsed)
    parsed["files"].map{|file| UserFile.new(file["extension"], file["size"])}
  end

  def extract_categories(files)
    categories = Hash.new
    files.each do |file|
      if categories[file.category]
        categories[file.category][:files_count] += 1
        categories[file.category][:total_weight] += file.weight
      else
        categories[file.category] = {files_count: 1, total_weight: file.weight}
      end
    end
    categories
  end
end