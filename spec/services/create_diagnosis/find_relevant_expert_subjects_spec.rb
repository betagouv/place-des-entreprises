# frozen_string_literal: true

require 'rails_helper'
describe CreateDiagnosis::FindRelevantExpertSubjects do
  describe 'apply_match_filters' do
    subject{ described_class.new(need).apply_match_filters(ExpertSubject.all) }

    let!(:es_temoin) { create :expert_subject }

    context 'min_years_of_existence' do
      let(:diagnosis) { create :diagnosis, company: company }
      let(:need) { create :need, diagnosis: diagnosis }
      let!(:es_01) { create :expert_subject }
      let(:match_filter_01) { create :match_filter, min_years_of_existence: 3 }

      before { es_01.expert.antenne.match_filters << match_filter_01 }

      context 'young company' do
        let(:company) { create :company, date_de_creation: 2.years.ago }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'old company' do
        let(:company) { create :company, date_de_creation: 7.years.ago }

        it { is_expected.to match_array [es_01, es_temoin] }
      end
    end

    context 'effectifs && subject' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:tresorerie_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, effectif_max: 20, subject_id: tresorerie_subject.id }
      let!(:es_01) { create :expert_subject }

      before { es_01.expert.antenne.match_filters << match_filter_01 }

      context 'only matching effectifs' do
        let(:facility) { create :facility, effectif: 19.4 }
        let(:need_subject) { create :subject }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'only matching subject' do
        let(:need_subject) { tresorerie_subject }
        let(:facility) { create :facility, effectif: 37.7 }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching subject and effectif' do
        let(:need_subject) { tresorerie_subject }
        let(:facility) { create :facility, effectif: 19.4 }

        it { is_expected.to match_array [es_temoin, es_01] }
      end
    end

    context 'code naf && subject' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:difficulte_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, accepted_naf_codes: ['1101Z', '1102A', '1102B'], subject_id: difficulte_subject.id }
      let!(:es_01) { create :expert_subject }

      before { es_01.expert.antenne.match_filters << match_filter_01 }

      context 'only matching naf' do
        let(:need_subject) { create :subject }
        let(:facility) { create :facility, naf_code: '1102A' }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'only matching subject' do
        let(:need_subject) { difficulte_subject }
        let(:facility) { create :facility, naf_code: '9001Z' }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching naf and subject' do
        let(:need_subject) { difficulte_subject }
        let(:facility) { create :facility, naf_code: '1102A' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end
    end

    context 'many filters' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis }

      let(:match_filter_01) { create :match_filter, effectif_min: 10 }
      let(:match_filter_02) { create :match_filter, min_years_of_existence: 3 }
      let!(:es_01) { create :expert_subject }

      before do
        es_01.expert.antenne.match_filters << match_filter_01
        es_01.expert.antenne.match_filters << match_filter_02
      end

      # On n'envoie pas si on n'a pas l'info
      context 'no facility filter data' do
        let(:facility) { create :facility, effectif: nil, company: create(:company, date_de_creation: nil) }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching none' do
        let(:facility) { create :facility, effectif: 9.9, company: create(:company, date_de_creation: 2.years.ago) }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching min_years_of_existence' do
        let(:facility) { create :facility, company: create(:company, date_de_creation: 4.years.ago) }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching effectif_min' do
        let(:facility) { create :facility, effectif: 10.1 }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching both' do
        let(:facility) { create :facility, effectif: 10.1, company: create(:company, date_de_creation: 4.years.ago) }

        it { is_expected.to match_array [es_temoin, es_01] }
      end
    end
  end

  describe 'call' do
    subject{ described_class.new(need).call }

    let(:diagnosis) { create :diagnosis, company: company }
    let(:need) { create :need, diagnosis: diagnosis }

    let!(:es_always) do
      create :expert_subject,
             institution_subject: create(:institution_subject, subject: the_subject, institution: create(:institution)),
             expert: create(:expert, communes: communes)
    end

    let!(:es_never) do
      create :expert_subject,
             institution_subject: create(:institution_subject, subject: the_subject, institution: create(:institution)),
             expert: create(:expert)
    end

    let!(:es_cci) do
      create :expert_subject,
             institution_subject: create(:institution_subject, subject: the_subject, institution: create(:institution, name: 'cci')),
             expert: create(:expert, communes: communes)
    end

    let!(:es_cma) do
      create :expert_subject,
             institution_subject: create(:institution_subject, subject: the_subject, institution: create(:institution, name: 'cma')),
             expert: create(:expert, communes: communes)
    end

    context 'no registre' do
      let(:company) { create :company, inscrit_rcs: true, inscrit_rm: true }
      let(:the_subject) { need.subject }
      let(:communes) { [need.facility.commune] }

      it{ is_expected.to match_array [es_always, es_cci, es_cma] }
    end
  end
end