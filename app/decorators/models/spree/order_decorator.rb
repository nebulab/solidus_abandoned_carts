# frozen_string_literal: true

module SolidusAbandonedCarts
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.scope :abandoned, ->(time = Time.current - SolidusAbandonedCarts::Config.abandoned_timeout) do
          incomplete.
            where('email IS NOT NULL').
            where('item_count > 0').
            where('updated_at < ?', time)
        end

        base.scope :abandon_not_notified, -> { abandoned.where(abandoned_cart_email_sent_at: nil) }
      end

      def last_for_user?
        ::Spree::Order.where(email: email).where('created_at > ?', created_at).none?
      end

      ::Spree::Order.prepend self
    end
  end
end
