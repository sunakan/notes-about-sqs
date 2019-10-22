config:
	docker-compose config

build:
	docker-compose build

up:
	docker-compose up -d

bash:
	docker-compose exec go bash

test:
	docker-compose exec app bundle exec rspec
	docker-compose exec go go test

down:
	docker-compose down

mq-size:
	aws sqs get-queue-attributes \
    --endpoint-url http://127.0.0.1:9324 \
    --queue-url http://127.0.0.1:9324/queue/sample.fifo \
    --attribute-names ApproximateNumberOfMessages \
      ApproximateNumberOfMessagesDelayed \
      ApproximateNumberOfMessagesNotVisible

