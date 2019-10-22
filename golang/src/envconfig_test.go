package main

import (
	"github.com/kelseyhightower/envconfig"
	"os"
	"testing"
)

// go test -vで失敗しなくても出力される
func TestEnvconfigHello(t *testing.T) {
	t.Log("HelloWorld")
}

// envconfigを使えば、以下のようなことが達成できる!!
//const (
//	AWS_REGION = os.Getenv("AWS_REGION") || "ap-northest-1"
//)
type Env struct {
	AWS_REGION string `envconfig:"AWS_REGION"  default:"ap-northest"`
}
func TestEnvconfig(t *testing.T) {
	region1 := os.Getenv("AWS_REGION")
	if region1 != "" {
		t.Log(region1)
		t.Fatal("region1は空文字で有るべき")
	}

	var goenv Env
	envconfig.Process("", &goenv)
	region2 := goenv.AWS_REGION
	if region2 == "" {
		t.Log(region2)
		t.Fatal("region2はデフォルト値が入っているべき")
	}
	// 代入は可能か? => 可能
	t.Log(goenv.AWS_REGION)
	goenv.AWS_REGION = "HELL WORLD"
	t.Log(goenv.AWS_REGION)
	// では定数としては。。。？ => 無理
	// 定数はコンパイル時に決定されるらしいので、評価式はだめっぽい
	//const MY_REGION := goenv.AWS_REGION
}
