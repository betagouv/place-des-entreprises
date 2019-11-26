# == Schema Information
#
# Table name: institutions_subjects
#
#  id             :bigint(8)        not null, primary key
#  description    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)
#  subject_id     :bigint(8)
#
# Indexes
#
#  index_institutions_subjects_on_institution_id  (institution_id)
#  index_institutions_subjects_on_subject_id      (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#  fk_rails_...  (subject_id => subjects.id)
#

class InstitutionSubject < ApplicationRecord
  belongs_to :institution, inverse_of: :institutions_subjects
  belongs_to :subject, inverse_of: :institutions_subjects

  has_many :experts_subjects, dependent: :destroy

  # :experts_subjects
  #
  has_many :experts, through: :experts_subjects, inverse_of: :experts

  scope :support_subjects, -> do
    where(subject: Subject.support_subject)
  end
end
