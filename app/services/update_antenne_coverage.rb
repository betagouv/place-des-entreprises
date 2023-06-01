require 'benchmark'

class UpdateAntenneCoverage
  def initialize(antenne)
    @antenne = antenne
  end

  def call
    time = Benchmark.measure do
      antenne_communes = @antenne.communes.pluck(:insee_code)

      institution_subjects = @antenne.institution.institutions_subjects
      institution_subjects.each do |institution_subject|
        subject_hash = antenne_communes.index_with {[]}
        experts_without_specific_territories = get_experts_without_specific_territories(antenne_communes, institution_subject)
        experts_with_specific_territories = get_experts_with_specific_territories(antenne_communes, institution_subject)

        experts_without_specific_territories.each do |expert|
          subject_hash[expert.insee_code] << expert.id
        end

        experts_with_specific_territories.each do |expert|
          subject_hash[expert.insee_code] << expert.id
        end

        register_coverage(institution_subject, subject_hash)
      end
      # TODO : if antenne.regional / antenne.national -> update children
    end
    puts "UpdateAntenneCoverage#call time : #{time}"
  end

  private

  def get_experts_without_specific_territories(insee_codes, institution_subject)
    institution_subject.not_deleted_experts
      .select('experts.id, experts.antenne_id, communes.insee_code AS insee_code')
      .joins(antenne: :communes)
      .where(antenne_id: all_potential_antennes_ids)
      .where(communes: { insee_code: insee_codes })
  end

  def get_experts_with_specific_territories(insee_codes, institution_subject)
    institution_subject.not_deleted_experts
      .select('experts.id, experts.antenne_id, communes.insee_code AS insee_code')
      .joins(:communes)
      .where(antenne_id: all_potential_antennes_ids)
      .where(communes: { insee_code: insee_codes })
  end

  def register_coverage(institution_subject, subject_hash)
    if subject_hash.values.all?([])
      no_expert(institution_subject)
    elsif subject_hash.values.any?([])
      missing_insee_codes(institution_subject, subject_hash)
    elsif subject_hash.values.any?{ |a| a.size > 1 }
      extra_insee_codes(institution_subject, subject_hash)
    else
      good_coverage(institution_subject, subject_hash)
    end
  end

  def good_coverage(institution_subject, code_experts_hash)
    all_experts = code_experts_hash.values.flatten.uniq
    # TODO : first_or_initialize
    ReferencementCoverage.create(
      institution_subject: institution_subject,
      antenne: @antenne,
      coverage: get_coverage(all_experts),
      anomalie: :no_anomalie,
      anomalie_details: nil
    )
  end

  #- que des experts avec communes, et somme des communes < antenne.communes
  #- /!\ et pas d'expert global sur le sujet
  #- /!\ et pas d'expert de l'antenne ou de la région sur le sujet sans code commune
  def missing_insee_codes(institution_subject, code_experts_hash)
    missing_codes = code_experts_hash.select{ |k,v| v.empty? }.keys
    all_experts = code_experts_hash.values.flatten.uniq

    ReferencementCoverage.create(
      institution_subject: institution_subject,
      antenne: @antenne,
      coverage: get_coverage(all_experts),
      anomalie: :missing_insee_codes,
      anomalie_details: {
        missing_insee_codes: missing_codes,
      }
    )
  end

  #- + d'un expert sans commune
  #- des experts avec communes + au moins un expert sans commune
  #- que des experts avec communes, et sommes des communes > antenne.communes
  def extra_insee_codes(institution_subject, code_experts_hash)
    extra_objects = code_experts_hash.select{ |k,v| v.size > 1 }
    extra_codes = extra_objects.keys
    extra_experts = extra_objects.values.flatten.uniq
    all_experts = code_experts_hash.values.flatten.uniq
    ReferencementCoverage.create(
      institution_subject: institution_subject,
      antenne: @antenne,
      coverage: get_coverage(all_experts),
      anomalie: :extra_insee_codes,
      anomalie_details: {
        extra_insee_codes: extra_codes,
        experts: extra_experts
      }
    )
  end

  def no_expert(institution_subject)
    ReferencementCoverage.create(
      institution_subject: institution_subject,
      antenne: @antenne,
      coverage: nil,
      anomalie: :no_expert,
      anomalie_details: { missing_insee_codes: @antenne_communes }
    )
  end

  def get_coverage(experts_ids)
    expert_antenne_ids = Expert.where(id: experts_ids).pluck(:antenne_id).uniq
    if expert_antenne_ids == [@antenne.id]
      :local
    elsif expert_antenne_ids.include?(@antenne.id)
      :mixte
    else
      :regional
    end
  end

  def all_potential_antennes_ids
    @all_potential_antennes ||= [
      @antenne.id,
      @antenne.regional_antenne.id,
      @antenne.institution.antennes.territorial_level_national.pluck(:id)
    ].flatten
  end
end
