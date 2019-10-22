package main

import (
	"os"
	"testing"
)

func TestHello(t *testing.T) {
	result := Hello()
	if result != "Hello" {
		t.Fatal("テスト失敗")
	}
}

func TestGetEnv(t *testing.T) {
	notExisted         := os.Getenv("NOT_EXISTED")
	awsAccessKeyId     := os.Getenv("AWS_ACCESS_KEY_ID")
	awsSecretAccessKey := os.Getenv("AWS_SECRET_ACCESS_KEY")
	if notExisted != "" {
		t.Fatal("環境変数NOT_EXISTEDは空文字であるべき")
	}
	if awsAccessKeyId != "dummy" {
		t.Fatal("環境変数AWS_ACCESS_KEY_IDはdummyであるべき")
	}
	if awsSecretAccessKey != "dummy" {
		t.Fatal("環境変数AWS_SECRET_ACCESS_KEYはdummyであるべき")
	}
}

// おこ
//const (
//	AWS_REGION = os.Getenv("AWS_REGION") || "ap-northest-1"
//)
const (
	AWS_REGION         = "AWS_REGION"
	DEFAULT_AWS_REGION = "ap-northest-1"
)
func TestConstAndEnvAndTLog(t *testing.T) {
	region := os.Getenv(AWS_REGION)
	t.Log(region)
	t.Log(DEFAULT_AWS_REGION)
	//t.Fatal("t.LogはFatalのときに初めて出力される。。？ => go test -v")
}
