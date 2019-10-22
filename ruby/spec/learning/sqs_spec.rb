require 'spec_helper'
require 'aws-sdk-sqs'
require 'json'

RSpec.describe "Learning Aws::Sqs::Client" do

  let(:endpoint) { ENV["SQS_ENDPOINT_URL"] || "https://sqs.ap-northeast-1.amazonaws.com" }
  let(:region)   { ENV["AWS_REGION"] || "ap-northeast-1" }
  let(:client)   { Aws::SQS::Client.new(endpoint: endpoint, region: region) }

  after(:context) do
    # afterではletが呼べないっぽい
    after_endpoint = ENV["SQS_ENDPOINT_URL"] || "https://sqs.ap-northeast-1.amazonaws.com"
    after_region   = ENV["AWS_REGION"] || "ap-northeast-1"
    after_client   = Aws::SQS::Client.new(endpoint: after_endpoint, region: after_region)
    # 最後に10個messageを詰めとく
    10.times do |idx|
      after_client.send_message({
        queue_url: ENV["SQS_QUEUE_URL"],
        message_body: {id: idx, name: "apple-#{idx}"}.to_json,
        message_group_id: "g-sample",
        message_deduplication_id: "hoge-#{idx}",
      })
    end
  end

  describe "hello" do
    it "hello" do
      expect("hello").to eq "hello"
    end
  end
  describe "clientを作る" do
    before do
      ENV["AWS_REGION"] = nil
    end
    it "Regionの指定が必要" do
      expect {
        Aws::SQS::Client.new(endpoint: endpoint)
      }.to raise_error(Aws::Errors::MissingRegionError)
    end
    it "client宣言成功" do
      expect(client.class).to eq Aws::SQS::Client
    end
    it "AWS_REGIONという環境変数を用意しておけば、Regionを明示的に指定する必要がない" do
      ENV["AWS_REGION"] = "ap-northeast-1"
      expect(Aws::SQS::Client.new(endpoint: endpoint).class).to eq Aws::SQS::Client
    end
  end

  describe "queue_listの取得" do
    it "まんま" do
      resp = client.list_queues
      expect(resp.class).to eq Seahorse::Client::Response
      expect(resp.successful?).to be_truthy
      expect(resp.queue_urls.size).to eq 2
    end
  end

  describe "queue_urlの取得" do
    it "queue_nameからqueue_urlを取得" do
      resp = client.get_queue_url({queue_name: "sample.fifo"})
      expect(resp.class).to eq Seahorse::Client::Response
      expect(resp.successful?).to be_truthy
      expect(resp.queue_url).to eq "http://localhost:9324/queue/sample.fifo"
    end
    it "存在しないqueue_nameを取得しようとするとエラー" do
      expect {
        client.get_queue_url({queue_name: "NOT_EXISTED"})
      }.to raise_error(Aws::SQS::Errors::NonExistentQueue)
    end
  end

  describe "messageを送るまで" do
    let(:queue_url)    { client.get_queue_url({queue_name: "sample.fifo"}).queue_url }
    it "rubyのclientだとqueue_urlがlocalhost:9324で駄目っぽい" do
      expect(queue_url).to eq "http://localhost:9324/queue/sample.fifo"
      expect {
        client.send_message({
          queue_url: queue_url,
          message_body: "helloworld"
        })
      }.to raise_error(Errno::EADDRNOTAVAIL)
    end
    it "FIFOだとMessageGroupIdが必須" do
      expect {
        client.send_message({
          queue_url: ENV["SQS_QUEUE_URL"],
          message_body: "helloworld",
        })
      }.to raise_error(Aws::SQS::Errors::MissingParameter, "The request must contain the parameter MessageGroupId.")
    end
    it "重複なしの設定かパラメータを入れる必要がある" do
      expect {
        client.send_message({
          queue_url: ENV["SQS_QUEUE_URL"],
          message_body: "helloworld",
          message_group_id: "g-sample",
        })
      }.to raise_error(Aws::SQS::Errors::InvalidParameterValue, "The queue should either have ContentBasedDeduplication enabled or MessageDeduplicationId provided explicitly")
    end
    it "メッセージを送る" do
      body = "helloworld"
      resp = client.send_message({
        queue_url: ENV["SQS_QUEUE_URL"],
        message_body: body,
        message_group_id: "g-sample",
        message_deduplication_id: "sample",
      })
      expect(resp.class).to eq Seahorse::Client::Response
      expect(resp.data.class).to eq Aws::SQS::Types::SendMessageResult
      expect(resp.data.md5_of_message_body).to eq OpenSSL::Digest::MD5.hexdigest(body)
    end
  end

  describe "queue sizeを確認したい" do
    before do
      client.purge_queue({
        queue_url: ENV["SQS_QUEUE_URL"],
      })
    end
    def send(unique_id: "id", body: "hello")
      client.send_message({
        queue_url: ENV["SQS_QUEUE_URL"],
        message_body: body,
        message_group_id: "g-sample",
        message_deduplication_id: unique_id,
      })
    end

    def queue_size()
      client.get_queue_attributes({
        queue_url: ENV["SQS_QUEUE_URL"],
        attribute_names: [
          "ApproximateNumberOfMessages",
          "ApproximateNumberOfMessagesNotVisible",
          "ApproximateNumberOfMessagesDelayed",
        ]
      }).data.attributes.values.map(&:to_i).sum
    end

    it "clearする" do
      resp = client.purge_queue({
        queue_url: ENV["SQS_QUEUE_URL"],
      })
      expect(resp.data.class).to eq Aws::EmptyStructure
    end

    it "messageの状態は3つあり、その合計値がQueueSize" do
      resp = client.get_queue_attributes({
        queue_url: ENV["SQS_QUEUE_URL"],
        attribute_names: [
          "ApproximateNumberOfMessages",
          "ApproximateNumberOfMessagesNotVisible",
          "ApproximateNumberOfMessagesDelayed",
        ]
      })
      expect(resp.data.class).to eq Aws::SQS::Types::GetQueueAttributesResult
      expect(resp.data.attributes.values.map(&:to_i).sum).to eq 0
    end

    it "重複したIDをちゃんと認識してくれる(設定した時間のみらしい)" do
      10.times do
        send(unique_id: "hoge", body: "hello")
      end
      expect(queue_size).to eq 1
    end

    it "uniqe_idをそれぞれ違う値にすると、ちゃんと全て入る" do
      10.times do |idx|
        send(unique_id: "hoge-#{idx}", body: "hello")
      end
      expect(queue_size).to eq 10
    end
  end
end
