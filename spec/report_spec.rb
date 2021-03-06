require "spec_helper"
require "report"

describe Report do
  let(:report) {Report.new}
  let(:response){ File.read("spec/sample_response.json") }
  let(:parsed) { report.json(response) }
  let(:files) { report.extract_files(parsed) }
  let(:categories) { report.extract_categories(files) }

  it "can load a user's files" do
    username = ENV['TEST_USERNAME']
    password = ENV['TEST_PASSWORD']
    response2 = report.list_files(username, password)
    expect(report.json(response2)).to have_key('files')
  end

  it "can parse the response" do
    expect(report.json(response)).to have_key('files')
  end

  it "can extract files from the parsed json" do
    expect(files.count).to eq 7
    expect(files[0].category).to eq "Video"
    expect(files[0].weight).to eq 14336.00
  end

  it "can return a hash of hashes with details about each category" do
    result = {files_count: 2, total_weight: 43008.00}
    expect(report.extract_categories(files)["Video"]).to eq result
  end

  it "can return a hash of hashes with details about each category" do
    result = {files_count: 2, total_weight: 3491.40}
    expect(report.extract_categories(files)["Document"]).to eq result
  end

  it "can return the total weight of files" do
    expect(report.total_weight(categories)).to eq 276282.20
  end

  it "can return the total ideal weight of files" do
    expect(report.total_ideal_weight(files)).to eq 262860.00
  end

  it "can return the total displacement of files" do
    expect(report.displacement(categories, files)).to eq 13422.20
  end

  it "can produce a report based on the input" do
    displacement = report.displacement(categories, files)
    total_weight = report.total_weight(categories)
    result = "My Files (category / gravity)\n2 Videos    43008.0\n1 Song    4300.8\n2 Documents    3491.4\n1 Binary    225280.0\n1 Text    202.0\n\nTotal:    276282.2\nDisplacement:    13422.2"
    expect(report.result(categories, displacement, total_weight)).to eq result
  end
end