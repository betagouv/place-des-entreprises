# == Schema Information
#
# Table name: company_satisfactions
#
#  id                  :bigint(8)        not null, primary key
#  comment             :text
#  contacted_by_expert :boolean
#  useful_exchange     :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  need_id             :bigint(8)        not null
#
# Indexes
#
#  index_company_satisfactions_on_need_id  (need_id)
#
# Foreign Keys
#
#  fk_rails_...  (need_id => needs.id)
#
class CompanySatisfaction < ApplicationRecord
  belongs_to :need, inverse_of: :company_satisfaction

  has_one :diagnosis, through: :need, inverse_of: :company_satisfactions
  has_one :solicitation, through: :diagnosis, inverse_of: :company_satisfactions
  has_one :landing, through: :solicitation, inverse_of: :solicitations
  has_one :landing_subject, through: :solicitation, inverse_of: :solicitations
  has_one :subject, through: :need, inverse_of: :needs
  has_one :theme, through: :need, source: :theme
  has_many :matches, through: :need, inverse_of: :need
  has_many :experts, through: :matches, source: :expert
  has_many :facility_regions, through: :need, inverse_of: :needs
  has_one :facility, through: :need, inverse_of: :needs

  has_many :shared_satisfactions, inverse_of: :company_satisfaction
  has_many :shared_satisfaction_users, through: :shared_satisfactions, source: :user
  has_many :shared_satisfaction_experts, -> { distinct }, through: :shared_satisfactions, source: :expert

  # Satisfaction pour les MER avec aide proposée
  has_many :done_matches, -> { status_done }, class_name: 'Match', through: :need, inverse_of: :need, source: :matches
  has_many :done_experts, class_name: 'Expert', through: :done_matches, source: :expert
  has_many :done_users, class_name: 'User', through: :done_experts, source: :users
  has_many :done_antennes, class_name: 'Antenne', through: :done_experts, source: :antenne
  has_many :done_institutions, class_name: 'Institution', through: :done_antennes, source: :institution

  validates :contacted_by_expert, :useful_exchange, inclusion: { in: [true, false] }
  validates_associated :shared_satisfactions

  scope :solicitation_mtm_campaign_cont, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_cont(query))
  }

  scope :solicitation_mtm_campaign_eq, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_eq(query))
  }

  scope :solicitation_mtm_campaign_start, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_start(query))
  }

  scope :solicitation_mtm_campaign_end, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_end(query))
  }

  scope :shared, -> { joins(:shared_satisfactions) }
  scope :not_shared, -> { where.missing(:shared_satisfactions) }

  scope :shared_eq, -> (query) do
    return self unless ['shared', 'not_shared'].include?(query)
    self.send(query)
  end

  scope :with_comment_eq, -> (query) {
    query == 'with_comment' ? where.not(comment: "") : where(comment: "")
  }

  def self.ransackable_scopes(auth_object = nil)
    %w[
      solicitation_mtm_campaign_cont solicitation_mtm_campaign_eq solicitation_mtm_campaign_start
      solicitation_mtm_campaign_end shared_eq experts_id_eq with_comment_eq
    ]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["comment", "contacted_by_expert", "created_at", "id", "id_value", "need_id", "updated_at", "useful_exchange"]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "done_antennes", "done_experts", "done_institutions", "done_matches", "facility_regions", "landing",
      "landing_subject", "matches", "need", "diagnosis", "solicitation", "subject", "theme", "facility", "experts"
    ]
  end

  # Partage aux conseillers
  #
  def share
    done_experts.find_each do |e|
      e.users.find_each{ |u| self.shared_satisfactions.create(user: u, expert: e) }
      expert_antenne = e.antenne
      expert_antenne.managers.each{ |u| self.shared_satisfactions.where(user: u).first_or_create(expert: e) }
      share_with_higher_manager(e, expert_antenne)
    end
    return true if self.valid?
    self.shared_satisfactions.map{ |us| us.errors.full_messages.to_sentence }.uniq.each do |error|
      self.errors.add(:base, error)
    end
    false
  end

  def share_with_higher_manager(e, antenne)
    if antenne.parent_antenne.present?
      antenne.parent_antenne.managers.each{ |u| self.shared_satisfactions.where(user: u).first_or_create(expert: e) }
      share_with_higher_manager(e, antenne.parent_antenne)
    end
  end

  def shared
    shared_satisfactions.any?
  end
end
