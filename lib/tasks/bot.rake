namespace :bot do
  desc "MoykaGo Telegram botini ishga tushirish (long polling)"
  task run: :environment do
    token = ENV["TELEGRAM_BOT_TOKEN"].presence
    token_file = Rails.root.join("config/telegram_token")
    token ||= File.read(token_file).strip if File.exist?(token_file)
    abort "Bot token topilmadi: TELEGRAM_BOT_TOKEN env yoki config/telegram_token fayli kerak." if token.blank?

    require "telegram/bot"
    puts "MoykaGo bot ishga tushdi (Ctrl+C — to'xtatish)..."
    Telegram::Bot::Client.run(token) do |bot|
      handler = Bot::Handler.new(bot.api)
      bot.listen do |update|
        handler.handle(update)
      rescue StandardError => e
        Rails.logger.error("BOT xatosi: #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      end
    end
  end
end
