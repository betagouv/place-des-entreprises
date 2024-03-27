# == Schema Information
#
# Table name: reminders_actions
#
#  id         :bigint(8)        not null, primary key
#  category   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  need_id    :bigint(8)        not null
#
# Indexes
#
#  index_reminders_actions_on_need_id               (need_id)
#  index_reminders_actions_on_need_id_and_category  (need_id,category) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (need_id => needs.id)
#
class RemindersAction < ApplicationRecord
  enum category: {
    poke: 1,          # J+9
    last_chance: 3,   # J+21
    abandon: 4,       # J+45
    refused: 5,       # Sortir du panier 'refusé'
    quo_match: 6,     # Sortir de la veille MER en attente
    starred_need: 7 # Sortie de la veille Besoin suivi
  }, _prefix: true

  ## Associations
  #
  belongs_to :need, inverse_of: :reminders_actions, touch: true

  ## Validations
  #
  validates :need, uniqueness: { scope: [:need_id, :category] }
end
