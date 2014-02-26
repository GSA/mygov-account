class Devise::Mailer < Devise.parent_mailer.constantize
  include Devise::Mailers::Helpers

  def confirmation_instructions(record, opts={})
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, opts={})
    devise_mail(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, opts={})
    devise_mail(record, :unlock_instructions, opts)
  end

  def reconfirmation_instructions(record, opts={})
    devise_mail(record, :reconfirmation_instructions, opts)
  end

  def you_changed_your_email_address(record, opts={})
    devise_mail(record, :you_changed_your_email_address, {to: record.email})
  end
end
