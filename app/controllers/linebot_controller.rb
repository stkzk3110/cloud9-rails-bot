class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'

    # callbackアクションのCSRFトークン認証を無効
    protect_from_forgery :except => [:callback]

    def callback
      body = request.body.read

      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
        head :bad_request
      end

      events = client.parse_events_from(body)

      events.each { |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            msg = event.message['text']
            if send_msg(msg)
              msg = change_msg(msg)
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: msg});
            else
              client.reply_message(event['replyToken'], {
                type: 'text',
                text: msg});
            end
          end
        end
      }
      head :ok
    end

    def send_msg(msg)
      if msg == 'マクドナルド'
        return true
      else
        false
      end
    end

    def change_msg(msg)
      case msg
      when "マクドナルド"
        return "i'm lovin' it!"
      end

    end

    private

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
  end
