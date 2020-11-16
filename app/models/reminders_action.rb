# == Schema Information
#
# Table name: reminders_actions
#
#  id       :bigint(8)        not null, primary key
#  category :enum             not null
#  need_id  :bigint(8)        not null
#
# Indexes
#
#  index_reminders_actions_on_category              (category)
#  index_reminders_actions_on_need_id               (need_id)
#  index_reminders_actions_on_need_id_and_category  (need_id,category) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (need_id => needs.id)
#
class RemindersAction < ApplicationRecord
  enum category: {
    poke: 'poke',
    recall: 'recall',
    warn: 'warn',
  }, _prefix: true

  ## Associations
  #
  belongs_to :need, inverse_of: :reminders_actions

  ## Validations
  #
  validates :need, uniqueness: { scope: [:need_id, :category] }
end
