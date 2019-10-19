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
