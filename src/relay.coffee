# Description:
#   Relay message to another chatbox via http
#
# Dependencies:
#   "coffee-script": "~1.6"
#
# Configuration:
#   RELAY_EVERYTHING - Relay message that didn't call bot name
#   RELAY_URL - URL relay to
#   RELAY_RESPONSE - Bot will respond even when relay successfully
#   RELAY_ENABLE_COMMAND - Support command
#   RELAY_ENABLE_RECEIVE - Enable receive relay message
#
# Commands:
#   Hubot relay add <url>
#   Hubot relay delete <url>
#   Hubot relay delete all
#   Hubot relay list <url>
#   Hubot relay <start|enable>
#   Hubot relay <stop|disable>
#   Hubot relay state
#
# Author:
#   clicia scarlet <yuyuvn@icloud.com>

module.exports = (robot) ->
  robot.catchAll (msg) ->
    r = new RegExp "^(?:#{robot.alias}|#{robot.name}) ([^]+)", "i"
    matches = msg.message.text.match(r)
    if matches != null && matches.length > 1
      message = matches[1]
    else
      return if !process.env.RELAY_EVERYTHING
      message = msg.message.text

    message = if robot.adapter.removeFormatting then robot.adapter.removeFormatting(message) else message
    if process.env.RELAY_ENABLE_COMMAND
      return if msg.message.text.match(/^(?:#{robot.alias}|#{robot.name}) relay /i) || !robot.brain.get(msg.message.user.name + "_relay_enable")
      urls = robot.brain.get(msg.message.user.name + "_relay_url") ||
        (if process.env.RELAY_URL then process.env.RELAY_URL.split("|") else null)
      msg.send "Relay Error! Use '#{robot.name} relay add <relay_url>' to add relay url" if !urls
    else
      return if !process.env.RELAY_URL
      urls = process.env.RELAY_URL.split "|"

    urls.forEach (url) ->
      data = JSON.stringify({msg: message})
      robot.http(url)
        .header('Content-Type', 'application/json')
        .post(data) (err, res, body) ->
          if err
            msg.send "Relay failed :(\n #{err}"
          else if process.env.RELAY_RESPONSE
            msg.send "Relay completed '#{message}'"

  robot.respond /relay add (.+)/, (msg) ->
    return if !process.env.RELAY_ENABLE_COMMAND
    url = msg.match[1]
    brain_key = msg.message.user.name + "_relay_url"
    list = robot.brain.get brain_key
    list = [] if !list
    list.push url
    robot.brain.set brain_key, list
    robot.brain.save
    msg.send "Added '#{url}' to relay list"

  robot.respond /relay delete (.+)/, (msg) ->
    return if !process.env.RELAY_ENABLE_COMMAND
    url = msg.match[1]
    brain_key = msg.message.user.name + "_relay_url"
    list = robot.brain.get brain_key
    if list
      index = list.indexOf(url)
      list.splice(index, 1) if index >= 0

    robot.brain.set brain_key, list
    robot.brain.save
    msg.send "Deleted '#{url}' from relay list"

  robot.respond /relay list/, (msg) ->
    return if !process.env.RELAY_ENABLE_COMMAND
    urls = robot.brain.get(msg.message.user.name + "_relay_url") || []
    msg.send "Relay list:\n" + urls.join("\n")

  robot.respond /relay delete all/, (msg) ->
    return if !process.env.RELAY_ENABLE_COMMAND
    robot.brain.set (msg.message.user.name + "_relay_url"), []
    robot.brain.save
    msg.send "Deleted all urls from relay list"

  robot.respond /relay (start|enable)/, (msg) ->
    return if !process.env.RELAY_ENABLE_COMMAND
    robot.brain.set (msg.message.user.name + "_relay_enable"), true
    robot.brain.save
    msg.send "Relay is enabled"

  robot.respond /relay (stop|disable)/, (msg) ->
    return if !process.env.RELAY_ENABLE_COMMAND
    robot.brain.set (msg.message.user.name + "_relay_enable"), false
    robot.brain.save
    msg.send "Relay is disabled"

  robot.respond /relay state/, (msg) ->
    return if !process.env.RELAY_ENABLE_COMMAND
    state = robot.brain.get (msg.message.user.name + "_relay_enable"), false
    state_mes = if state then "enabled" else "disabled"
    msg.send "Relay is #{state_mes}"

  robot.router.post "/hubot/relay/:room", (req, res) ->
    return if !process.env.RELAY_ENABLE_RECEIVE
    room = req.params.room
    msg = req.body.msg
    robot.messageRoom room, msg
    res.send 'OK'
