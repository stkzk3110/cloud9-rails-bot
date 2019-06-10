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
        config.channel_secret = "36674aa7a7beb7289c5d40ebef4829d1"
        config.channel_token = "NXGApTHf8F78/pYtc5FdeE7ci3w5ajyXdAYng3gYVUvZE/7KI/Ib9kelOLwMvMratkAosyqv/zNQfHxI+NtenaFhQuBHGba/i29eOxW1I8V1uu1+ySsFlY160utrDWzJfRm2fZg9sqmouled5/8jWQdB04t89/1O/w1cDnyilFU="
      }
    end
  end
