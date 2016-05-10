# Microscaling queue-demo

Simple demo for showing how the [Microscaling agent](https://github.com/microscaling/microscaling) can scale a queue to maintain a target length. Demo currently supports [NSQ](http://nsq.io/) (more queues will be supported soon). The demo is implemented in Ruby and intended to be run as a Docker container.

[![](https://badge.imagelayers.io/microscaling/queue-demo:latest.svg)](https://imagelayers.io/?images=microscaling/queue-demo:latest 'Get your own badge on imagelayers.io')

Each Docker command is shown along with its environment variables and default values.

## consumer

Consumer is the default Docker command and adds items to the queue.

```
MSS_QUEUE_ENDPOINT    127.0.0.1:4150
MSS_TOPIC_NAME        microscaling-demo
MSS_CHANNEL_NAME      microscaling-demo
MSS_CONSUMER_SLEEP_MS 300
```

## producer

Producer removes items from the queue.

```
MSS_QUEUE_ENDPOINT    127.0.0.1:4150
MSS_TOPIC_NAME        microscaling-demo
MSS_PRODUCER_SLEEP_MS 100
```

## marathon_setup

Creates the demo apps using the Marathon REST API. You can register at [app.microscaling.com](https://app.microscaling.com) to get your MSS_USER_ID.
MSS_MARATHON_API should be your Marathon endpoint e.g. http://m1.dcos:8080

```
MSS_API_ADDRESS       api.microscaling.com
MSS_USER_ID            
MSS_MARATHON_API       
```

## marathon_teardown

Deletes the demo apps using the Marathon REST API.

```
MSS_MARATHON_API 
```

## Development

Use Docker Compose to develop and test changes to the demo. From the current directory
run the up command.

```
$ docker-compose up
```

