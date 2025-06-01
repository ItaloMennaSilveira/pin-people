require 'rails_helper'

RSpec.describe CsvReaderService do
  let(:filepath) { Rails.root.join('spec/temp/sample.csv') }

  before do
    File.write(filepath, "col1;col2\nvalue1;value2\n")
  end

  after { File.delete(filepath) }

  it "reads CSV and returns an array of hashes" do
    result = described_class.new(filepath).call
    expect(result).to eq([{ "col1" => "value1", "col2" => "value2" }])
  end
end
