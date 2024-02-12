module MailtoHelper
  def mailto_contact_us(text = ENV['APPLICATION_REPLY_TO_EMAIL'], klass = '')
    mail_to ENV['APPLICATION_EMAIL'], text, target: :_blank, class: klass
  end
end
