class Conversations::FollowUpJob < ApplicationJob
  queue_as :low

  def perform(account:)
    conversations = account.conversations.awaiting_follow_up(account.follow_up_after)
                           .limit(Limits::BULK_ACTIONS_LIMIT)

    conversations.each do |conversation|
      ::MessageTemplates::Template::FollowUp.new(conversation: conversation).perform
      # rubocop:disable Rails/SkipsModelValidations
      conversation.update_column(:follow_up_sent_at, Time.current)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
