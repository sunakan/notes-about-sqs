package main

import (
	"testing"
)

func TestHello(t *testing.T) {
	result := Hello()
	if result != "Hello" {
		t.Fatal("テスト失敗")
	}
}
