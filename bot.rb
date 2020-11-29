require_relative 'config.rb'
require_relative 'generator.rb'
require 'telegram/bot'
require 'redis'
require 'json'

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when '/cv@ResumemeBot', '/cv', '/cv@resumeme_bot'
      user = message.from
      chat_id = message.chat.id
      name = [user.first_name, user.last_name].join(' ')
      redis = Redis.new
      params = {
        username: user.username,
        name: name,
        redis: redis,
        chat_id: chat_id
      }
      resume = Generator.new(params).cv
      redis.incr('all')
      redis.close
      bot.api.send_message(chat_id: chat_id, text: resume.values.join("\n"))
    when '/stats@ResumemeBot', '/stats@resumeme_bot'
      chat_id = message.chat.id
      redis = Redis.new
      result = JSON.parse(redis.get(chat_id))
      bot.api.send_message(chat_id: chat_id, text: "Самая топовая зарплата у #{result['username']} - #{result['biggest']} рублей 🤑")
      redis.close
    end
  end
end
