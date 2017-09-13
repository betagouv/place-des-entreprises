# frozen_string_literal: true

module UseCases
  class GetDiagnoses
    class << self
      def for_user(user)
        user_diagnoses = Diagnosis.of_user(user).reverse_chronological
        in_progress_associations = [visit: [facility: [:company]]]
        {
          in_progress: user_diagnoses.in_progress.includes(in_progress_associations),
          completed: completed_diagnoses_from_user_diagnoses(user_diagnoses)
        }
      end

      private

      def completed_diagnoses_from_user_diagnoses(diagnoses)
        completed_associations = [
          visit: [:visitee, facility: [:company]], diagnosed_needs: [:selected_assistance_experts]
        ]
        diagnoses = diagnoses.completed.includes(completed_associations)
        diagnoses = Diagnosis.enrich_with_diagnosed_needs_count(diagnoses)
        Diagnosis.enrich_with_selected_assistances_experts_count(diagnoses)
      end
    end
  end
end
