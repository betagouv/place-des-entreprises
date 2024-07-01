# == Schema Information
#
# Table name: shared_satisfactions
#
#  id                      :bigint(8)        not null, primary key
#  seen_at                 :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  company_satisfaction_id :bigint(8)        not null
#  expert_id               :bigint(8)        not null
#  user_id                 :bigint(8)        not null
#
# Indexes
#
#  index_shared_satisfactions_on_company_satisfaction_id  (company_satisfaction_id)
#  index_shared_satisfactions_on_expert_id                (expert_id)
#  index_shared_satisfactions_on_user_id                  (user_id)
#  shared_satisfactions_references_index                  (user_id,company_satisfaction_id,expert_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (company_satisfaction_id => company_satisfactions.id)
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (user_id => users.id)
#
class SharedSatisfaction < ApplicationRecord
  belongs_to :company_satisfaction, inverse_of: :shared_satisfactions, touch: true
  belongs_to :user, inverse_of: :shared_satisfactions
  belongs_to :expert, inverse_of: :shared_satisfactions

  has_one :need, through: :company_satisfaction

  validates :user_id, uniqueness: { scope: [:company_satisfaction_id, :expert_id] }
  validate :satisaction_has_comment

  scope :unseen, -> { where(seen_at: nil) }
  scope :seen, -> { where.not(seen_at: nil) }

  def seen?
    seen_at.present?
  end

  def unseen?
    seen_at.blank?
  end

  private

  def satisaction_has_comment
    self.errors.add(:base, I18n.t('errors.satisfaction_without_comment')) if (company_satisfaction.comment.blank?)
  end
end
