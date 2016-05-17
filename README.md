# Microscaling Queue Demo

Supporting demo images for the [Microscaling Engine](https://github.com/microscaling/microscaling) from [Microscaling Systems](https://microscaling.com). Used to show how the engine can scale a queue to maintain a target length.

## Marathon Demo with Azure Storage Queue

The marathon-install and marathon-uninstall commands creates the Marathon demo apps using its REST API. See this [blog post](http://blog.microscaling.com/2016/05/microscaling-marathon-with-dcos-on.html) for more details. To run the commands you need Ruby but there are no other dependencies.

### marathon-install

Creates the demo apps using the Marathon REST API. You can register at [app.microscaling.com](https://app.microscaling.com) to get your install command.

### marathon-uninstall

Deletes the demo apps using the Marathon REST API.

## Docker Demo with NSQ.

Used for the [microscaling/queue-demo](https://hub.docker.com/r/microscaling/queue-demo/) Docker image.

[![](https://badge.imagelayers.io/microscaling/queue-demo:latest.svg)](https://imagelayers.io/?images=microscaling/queue-demo:latest 'Get your own badge on imagelayers.io')

Each Docker command is shown along with its environment variables and default values.

### consumer

The default Docker command that adds items to the queue.

```
MSS_QUEUE_ENDPOINT    127.0.0.1:4150
MSS_TOPIC_NAME        microscaling-demo
MSS_CHANNEL_NAME      microscaling-demo
MSS_CONSUMER_SLEEP_MS 300
```

### producer

The producer command removes items from the queue.

```
MSS_QUEUE_ENDPOINT    127.0.0.1:4150
MSS_TOPIC_NAME        microscaling-demo
MSS_PRODUCER_SLEEP_MS 100
```

## Development

Use Docker Compose to develop and test changes to the demo. From the current directory
run the up command.

```
$ docker-compose up
```
