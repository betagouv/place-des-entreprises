# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  belongs_to :visit

  has_many :diagnosed_needs
  accepts_nested_attributes_for :diagnosed_needs

  validates :visit, presence: true

  scope :of_visit, (->(visit) { where(visit: visit) })

  def creation_date_localized
    I18n.l(created_at.to_date)
  end
end
