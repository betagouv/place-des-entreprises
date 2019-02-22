# == Schema Information
#
# Table name: solicitations
#
#  id           :bigint(8)        not null, primary key
#  description  :string
#  email        :string
#  form_info    :jsonb
#  needs        :jsonb
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Solicitation < ApplicationRecord
  ## Associations
  #

  ## Validations
  #
  validates :email, format: { with: PersonConcern::EMAIL_REGEXP }, allow_blank: true

  ## “Through” Associations
  #

  ## Scopes
  #
  scope :of_campaign, -> (campaign) { where("form_info->>'pk_campaign' = ?", campaign) }
  scope :of_alternative, -> (alternative) { where("form_info->>'alternative' = ?", alternative) }

  ## JSON Accessors
  #
  TRACKING_KEYS = %i[pk_source pk_medium pk_campaign pk_content pk_kwd]
  FORM_INFO_KEYS = [:alternative] + TRACKING_KEYS
  store_accessor :form_info, FORM_INFO_KEYS.map(&:to_s)

  ## ActiveAdmin/Ransacker helpers
  #
  FORM_INFO_KEYS.each do |key|
    ransacker key do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:form_info], Arel::Nodes.build_quoted(key.to_s))
    end
  end

  ##
  #
  def to_s
    "#{self.class.model_name.human} #{id}"
  end
end
