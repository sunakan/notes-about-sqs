require 'spec_helper'
require 'aws-sdk-sqs'

RSpec.describe "Learning Aws::Sqs::Client" do
  describe "hello" do
    it "hello" do
      expect("hello").to eq "hello"
    end
  end

  let(:endpoint) { ENV["SQS_ENDPOINT_URL"] || "https://sqs.ap-northeast-1.amazonaws.com" }
  let(:region)   { ENV["AWS_REGION"] || "ap-northeast-1" }
  let(:client)   { Aws::SQS::Client.new(endpoint: endpoint, region: region) }

  describe "clientを作る" do
    it "Regionの指定が必要" do
      expect {
        Aws::SQS::Client.new(endpoint: endpoint)
      }.to raise_error(Aws::Errors::MissingRegionError)
    end
    it "client宣言成功" do
      expect(client.instance_of?(Aws::SQS::Client)).to be_truthy
    end
  end
end
