ARG TAG=1.13-buster
FROM golang:${TAG}

RUN go get github.com/aws/aws-sdk-go-v2/service/sqs \
  && go get github.com/kelseyhightower/envconfig
