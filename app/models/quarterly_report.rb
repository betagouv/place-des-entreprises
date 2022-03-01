# == Schema Information
#
# Table name: quarterly_reports
#
#  id         :bigint(8)        not null, primary key
#  end_date   :date
#  start_date :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  antenne_id :bigint(8)        not null
#
# Indexes
#
#  index_quarterly_reports_on_antenne_id  (antenne_id)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#
class QuarterlyReport < ApplicationRecord
  belongs_to :antenne, inverse_of: :quarterly_reports
  has_one_attached :file
end
