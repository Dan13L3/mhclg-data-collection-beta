class DeviseNotifyMailer < Devise::Mailer
  require "notifications/client"

  def notify_client
    @notify_client ||= ::Notifications::Client.new(ENV["GOVUK_NOTIFY_API_KEY"])
  end

  def send_email(email, template_id, personalisation)
    notify_client.send_email(
      email_address: email,
      template_id:,
      personalisation:,
    )
  end

  def personalisation(record, token, url)
    {
      name: record.name || record.email,
      email: record.email,
      organisation: record.respond_to?(:organisation) ? record.organisation.name : "",
      link: "#{url}#{token}",
    }
  end

  def reset_password_instructions(record, token, _opts = {})
    base = public_send("edit_#{record.class.name.underscore}_password_url")
    url = "#{base}?reset_password_token="
    send_email(
      record.email,
      record.reset_password_notify_template,
      personalisation(record, token, url),
    )
  end

  def confirmation_instructions(record, token, _opts = {})
    url = "#{user_confirmation_url}?confirmation_token="
    send_email(
      record.email,
      record.confirmable_template,
      personalisation(record, token, url),
    )
  end

  # def unlock_instructions(record, token, opts = {})
  #   super
  # end
  #
  # def email_changed(record, opts = {})
  #   super
  # end
  #
  # def password_change(record, opts = {})
  #   super
  # end
end
