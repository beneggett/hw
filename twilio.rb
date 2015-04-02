class Messenger
  require 'twilio-ruby'

  attr_accessor :client
  def initialize
    account_sid = 'mysecret'
    auth_token = 'mytoken'
    @client = Twilio::REST::Client.new account_sid, auth_token
  end

  def message(body,  to = '+8015555555', from = '+18015555555')
    @client.account.messages.create(
      from: from,
      to: to,
      body: body
    )
  end

  def picture_message(body, media_url = nil,  to = '+8015555555', from = '+18015555555')
    @client.account.messages.create(
      from: from,
      to: to,
      body: body,
      media_url: media_url
    )
  end
end

