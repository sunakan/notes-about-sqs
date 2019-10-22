package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/kelseyhightower/envconfig"
	"testing"
)

// go test -vで失敗しなくても出力される
func TestSqs(t *testing.T) {
	t.Log("HelloWorld")
}

type SqsEnv struct {
	AWS_REGION string `envconfig:"AWS_REGION" default:"ap-northest-1"`
	AWS_ACCESS_KEY_ID string `envconfig:"AWS_ACCESS_KEY_ID" default:"dummy"`
	AWS_SECRET_ACCESS_KEY string `envconfig:"AWS_SECRET_ACCESS_KEY" default:"dummy"`
	SQS_ENDPOINT_URL string `envconfig:"SQS_ENDPOINT_URL" default:"http://mq:9324"`
	SQS_QUEUE_URL string `envconfig:"SQS_QUEUE_URL" default:"http://mq:9324/queue/sample.fifo"`
	SQS_QUEUE_NAME string `envconfig:"SQS_QUEUE_NAME" default:"sample.fifo"`
	//SQS_ENDPOINT_URL string `"SQS_ENDPOINT_URL" default: "http://mq:9324/queue/sample.fifo"`
}

type Sqs struct {
	Sqs *sqs.SQS
	Url string
}

func TestClient(t *testing.T) {
	var goenv SqsEnv
	envconfig.Process("", &goenv)
	// ここから
	newSession, _ := session.NewSession(&aws.Config {
		Endpoint: aws.String(goenv.SQS_ENDPOINT_URL),
		Region: aws.String(goenv.AWS_REGION),
	})
	svc := sqs.New(newSession)
	sqs := new(Sqs)
	v, err := newSession.Config.Credentials.Get()
	sqs.Sqs = svc
	sqs.Url = goenv.SQS_ENDPOINT_URL
	t.Log(err, v.AccessKeyID, " --- ", v.SecretAccessKey)
	t.Log(svc)
}

func TestGetQueueUrl(t *testing.T) {
	var goenv SqsEnv
	envconfig.Process("", &goenv)
	// ここから
	newSession, _ := session.NewSession(&aws.Config {
		Endpoint: aws.String(goenv.SQS_ENDPOINT_URL),
		Region: aws.String(goenv.AWS_REGION),
	})
	svc := sqs.New(newSession)
	sqsQueueName := goenv.SQS_QUEUE_NAME
	queueUrl, err := svc.GetQueueUrl(&sqs.GetQueueUrlInput{QueueName: &sqsQueueName})
	if err != nil {
		t.Log(sqsQueueName)
		t.Log(err)
		t.Fatal("取れなかった")
	}
	t.Log("取れた")
	t.Log(queueUrl)
}

func TestReceiveMessage(t *testing.T) {
	var goenv SqsEnv
	envconfig.Process("", &goenv)
	newSession, _ := session.NewSession(&aws.Config {
		Endpoint: aws.String(goenv.SQS_ENDPOINT_URL),
		Region: aws.String(goenv.AWS_REGION),
	})
	svc := sqs.New(newSession)
	params := &sqs.ReceiveMessageInput{
		QueueUrl: aws.String(goenv.SQS_QUEUE_URL), // Required
		AttributeNames: []*string{
			aws.String("QueueAttributeName"), // Required
			// More values...
		},
		MaxNumberOfMessages: aws.Int64(5),
		//MessageAttributeNames: []*string{
		//	aws.String("MessageAttributeName"), // Required
		//	// More values...
		//},
		//ReceiveRequestAttemptId: aws.String("String"),
		VisibilityTimeout:       aws.Int64(1),
		WaitTimeSeconds:         aws.Int64(1),
	}
	resp, err := svc.ReceiveMessage(params)
	if err != nil {
		t.Log("取得失敗")
		t.Fatal(err)
	}
	t.Log(resp.Messages)
	for idx, message := range resp.Messages {
		t.Log("===========", idx)
		t.Log(message.Body)
	}
}
