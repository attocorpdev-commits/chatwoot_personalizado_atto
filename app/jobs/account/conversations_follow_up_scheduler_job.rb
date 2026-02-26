class Account::ConversationsFollowUpSchedulerJob < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    Account.with_follow_up.find_each(batch_size: 100) do |account|
      Conversations::FollowUpJob.perform_later(account: account)
    end
  end
end
