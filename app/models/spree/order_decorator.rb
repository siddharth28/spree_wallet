Spree::Order.class_eval do
  def user_or_by_email
    user ? user : Spree::User.where(:email => email).first
  end

  def has_unprocessed_payments?
    payments.with_state('checkout').reload.exists? || (available_wallet_payment_method.present? && (wallet_payment = payments.where(:payment_method_id => available_wallet_payment_method.id).last).present? && wallet_payment.amount <= remaining_total)
  end

  def remaining_total
    total - payment_total
  end

  def available_payment_methods_without_wallet
    available_payment_methods.reject { |p| p.is_a? Spree::PaymentMethod::Wallet }
  end

  def available_wallet_payment_method
    @wallet_payment_method ||= available_payment_methods.select { |p| p.is_a? Spree::PaymentMethod::Wallet }.first
  end

  def other_than_wallet_payment_required?
    remaining_total > user.store_credits_total
  end

  def available_wallet_payment_amount
    [remaining_total, user_or_by_email.store_credits_total].min
  end

  def display_available_wallet_payment_amount
    Spree::Money.new(available_wallet_payment_amount)
  end

  def remaining_total_after_wallet
    remaining_total -  available_wallet_payment_amount
  end

  def display_remaining_total_after_wallet
    Spree::Money.new(remaining_total_after_wallet)
  end
end