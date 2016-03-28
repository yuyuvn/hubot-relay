hubot-relay
============

Relay message to another chatbox via http


## Installation

Add **hubot-relay** to your `package.json` file:

```json
"dependencies": {
  "hubot-relay": "*"
}
```

OR run `npm install --save hubot-relay`

Add **hubot-relay** to your `external-scripts.json`:

```json
["hubot-relay"]
```

Run `npm install`


## Configuration

```
RELAY_EVERYTHING - Relay message that didn't call bot name
RELAY_URL - URL relay to
RELAY_RESPONSE - Bot will respond even when relay successfully
RELAY_ENABLE_COMMAND - Support command
RELAY_ENABLE_RECEIVE - Enable receive relay message
```

- Uri is http://<your_receiver_address>/hubot/relay/<room_id>
