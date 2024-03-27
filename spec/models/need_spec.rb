# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Need do
  describe 'associations' do
    it do
      is_expected.to belong_to :diagnosis
      is_expected.to belong_to :subject
      is_expected.to have_many :matches
      is_expected.to belong_to :diagnosis
    end
  end

  describe 'subject uniqueness in the scope of a diagnosis' do
    subject { build :need, diagnosis: diagnosis, subject: subject1 }

    let(:diagnosis) { create :diagnosis }
    let(:subject1) { create :subject }

    context 'unique need for this subject' do
      it { is_expected.to be_valid }
    end

    context 'need for another subject' do
      before { create :need, diagnosis: diagnosis, subject: subject2 }

      let(:subject2) { create :subject }

      it { is_expected.to be_valid }
    end

    context 'need for the same subject' do
      before { create :need, diagnosis: diagnosis, subject: subject1 }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'update_status' do
    context 'after match changes' do
      let(:need) { create :need_with_matches }

      before { need.matches.first.update(status: :taking_care) }

      subject { need.reload.status }

      it { is_expected.to eq 'taking_care' }
    end

    context 'after diagnosis changes' do
      let(:need) { create :need }

      before do
        need.matches << create(:match)
      end

      it 'changes need status' do
        expect(need.status).to eq('diagnosis_not_complete')
        need.diagnosis.update(step: :completed)
        expect(need.reload.status).to eq('quo')
      end
    end
  end

  describe 'status' do
    subject { need.status }

    let(:need) { create :need, matches: matches, diagnosis: create(:diagnosis_completed) }

    context 'diagnosis not complete' do
      let(:need) { create :need, diagnosis: create(:diagnosis, step: :not_started) }

      it { is_expected.to eq 'diagnosis_not_complete' }
    end

    context 'with no match' do
      let(:matches) { [] }

      it{ is_expected.to eq 'diagnosis_not_complete' }
    end

    context 'diagnosis complete' do
      rules = {
        %i[quo quo] => 'quo',
        %i[quo not_for_me] => 'quo',
        %i[quo taking_care] => 'taking_care',
        %i[quo taking_care not_for_me] => 'taking_care',
        %i[quo done] => 'done',
        %i[quo taking_care not_for_me done] => 'done',
        %i[done done_no_help] => 'done',
        %i[done done_not_reachable done_no_help] => 'done',
        %i[quo done_no_help] => 'done_no_help',
        %i[taking_care done_no_help] => 'done_no_help',
        %i[done_not_reachable done_no_help] => 'done_no_help',
        %i[quo done_not_reachable not_for_me] => 'done_not_reachable',
        %i[not_for_me not_for_me] => 'not_for_me',
      }
      rules.each do |matches_statuses, need_status|
        # Building test dynamically for each rule
        context "#{matches_statuses.join(', ')} => #{need_status}" do
          let(:matches) { matches_statuses.map{ |status| build(:match, status: status) } }

          it{ is_expected.to eq need_status }
        end
      end
    end
  end

  describe 'scopes' do
    describe 'with_some_matches_in_status' do
      subject { described_class.with_some_matches_in_status(:done) }

      let(:need) { create :need }

      before { create :need }

      context 'with no match' do
        it { is_expected.to match_array [] }
      end

      context 'with matches, not done' do
        before do
          create :match, need: need, status: :quo
        end

        it { is_expected.to match_array [] }
      end

      context 'with matches, done' do
        before do
          create :match, need: need, status: :quo
          create :match, need: need, status: :done
        end

        it { is_expected.to contain_exactly(need) }
      end
    end

    describe 'with_matches_only_in_status' do
      subject { described_class.with_matches_only_in_status(:quo) }

      let(:need1) { create :need }
      let(:need2) { create :need }
      let(:need3) { create :need }

      context 'with no match' do
        it { is_expected.to match_array [] }
      end

      context 'with various matches' do
        before do
          create_list :match, 2, status: :quo, need: need1
          create :match, status: :quo, need: need2
          create :match, status: :taking_care, need: need2
          create :match, status: :done, need: need3
          create :match, status: :not_for_me, need: need3
        end

        it { is_expected.to contain_exactly(need1) }
      end
    end

    describe 'ordered_for_interview' do
      subject { described_class.ordered_for_interview }

      context 'with subjects and themes' do
        let(:t1)    { create :theme, interview_sort_order: 1 }
        let(:t2)    { create :theme, interview_sort_order: 2 }
        let(:s1)    { create :subject, interview_sort_order: 1, theme: t1 }
        let(:s2)    { create :subject, interview_sort_order: 2, theme: t1 }
        let(:s3)    { create :subject, interview_sort_order: 1, theme: t2 }
        let(:s4)    { create :subject, interview_sort_order: 2, theme: t2 }
        let(:need1) { create  :need, subject: s1 }
        let(:need2) { create  :need, subject: s2 }
        let(:need3) { create  :need, subject: s3 }
        let(:need4) { create  :need, subject: s4 }

        it { is_expected.to contain_exactly(need1, need2, need3, need4) }
      end
    end

    describe 'active' do
      subject { described_class.active }

      let!(:need1) do
        create :need, matches: [
          create(:match, status: :quo),
          create(:match, status: :not_for_me),
        ]
      end
      let!(:need2) do
        create :need, matches: [
          create(:match, status: :taking_care),
          create(:match, status: :quo),
        ]
      end

      before do
        create :need, matches: [
          create(:match, status: :quo),
          create(:match, status: :done),
        ]
        create :need, matches: [
          create(:match, status: :not_for_me)
        ]
      end

      it { is_expected.to contain_exactly(need1, need2) }
    end

    describe 'without_action' do
      # Exclue les besoins qui ont des reminders_action d'une catégorie en particulier
      # 1- besoin sans reminders_action
      # 2- besoin avec une action poke
      # 3- besoin avec une action last_chance
      # 4- besoin avec une action last_chance et une poke

      let!(:need1) { create :need }
      let(:need2) { create :need }
      let!(:reminders_action2) { create :reminders_action, category: :poke, need: need2 }
      let(:need3) { create :need }
      let!(:reminders_action3) { create :reminders_action, category: :last_chance, need: need3 }
      let(:need4) { create :need }
      let!(:reminders_action4) { create :reminders_action, category: :last_chance, need: need4 }
      let!(:reminders_action4_2) { create :reminders_action, category: :poke, need: need4 }

      it 'expect to have needs without poke action' do
        expect(described_class.without_action(:poke))
          .to contain_exactly(need1, need3)
      end

      it 'expect to have needs without last_chance action' do
        expect(described_class.without_action(:last_chance))
          .to contain_exactly(need1, need2)
      end
    end

    describe 'feedbacks' do
      let(:need) { create :need }
      let!(:feedback1) { create :feedback, :for_need_reminder, feedbackable: need }
      let!(:feedback2) { create :feedback, :for_need, feedbackable: need }

      it 'return only feedbacks for reminders' do
        expect(need.reminder_feedbacks).to contain_exactly(feedback1)
      end

      it 'return only feedbacks for diagnosis page' do
        expect(need.feedbacks).to contain_exactly(feedback2)
      end
    end

    describe 'for_emails_and_sirets' do
      let(:email) { 'dupond@dupont.fr' }
      let(:other_email) { 'tintin@moulinsart.fr' }
      let(:facility) { create :facility, siret: siret }
      let(:solicitation) { create :solicitation, email: email }
      let(:solicitation2) { create :solicitation, email: email }
      let(:solicitation3) { create :solicitation, email: email }
      let(:solicitation4) { create :solicitation, email: email }
      let(:solicitation5) { create :solicitation, email: email }
      let(:other_email_solicitation) { create :solicitation, email: other_email }
      let(:other_email_solicitation2) { create :solicitation, email: other_email }

      context 'with email and siret not nil' do
        let(:siret) { '42322944200011' }
        let(:other_facility) { create :facility, siret: '32242373200021' }
        #  Besoin avec le meme email OK
        let(:diagnosis_1) { create :diagnosis, solicitation: solicitation, visitee: create(:contact, email: email) }
        let!(:need_1) { create :need_with_matches, diagnosis: diagnosis_1 }
        # Besoin avec le même email et le même siret OK
        let(:diagnosis_2) { create :diagnosis, solicitation: solicitation2, facility: facility, visitee: create(:contact, email: email) }
        let!(:need_2) { create :need_with_matches, diagnosis: diagnosis_2 }
        # Besoin avec un autre email KO
        let(:diagnosis_3) { create :diagnosis, solicitation: other_email_solicitation, visitee: create(:contact, email: other_email) }
        let!(:need_3) { create :need_with_matches, diagnosis: diagnosis_3 }
        # Besoin avec un autre email et siret KO
        let(:diagnosis_4) { create :diagnosis, solicitation: other_email_solicitation2, facility: other_facility, visitee: create(:contact, email: other_email) }
        let!(:need_4) { create :need_with_matches, diagnosis: diagnosis_4 }
        # Besoin avec le même email mais sans MER KO
        let(:diagnosis_5) { create :diagnosis, solicitation: solicitation3, visitee: create(:contact, email: email) }
        let!(:need_5) { create :need, diagnosis: diagnosis_5 }
        # Besoin avec le même siret mais sans MER KO
        let(:diagnosis_6) { create :diagnosis, solicitation: solicitation5, facility: facility, visitee: create(:contact, email: email) }
        let!(:need_6) { create :need, diagnosis: diagnosis_6 }

        subject { described_class.for_emails_and_sirets([email], [siret]) }

        it 'return needs historic for email and siret' do
          is_expected.to contain_exactly(need_1, need_2)
        end
      end

      context 'with nil siret' do
        let(:siret) { nil }
        let(:diagnosis) { create :diagnosis, solicitation: solicitation }
        let!(:need) { create :need_with_matches, diagnosis: diagnosis }
        let(:diagnosis_siret_nil) { create :diagnosis, solicitation: other_email_solicitation, facility: facility }
        let!(:need_siret_nil) { create :need_with_matches, diagnosis: diagnosis_siret_nil }

        subject { described_class.for_emails_and_sirets([email], [siret]) }

        it 'not return need with' do
          is_expected.to contain_exactly(need)
        end
      end
    end

    describe 'min_closed_with_help_at' do
      subject { described_class.min_closed_with_help_at(date_range) }

      let(:date_range) { 12.days.ago..8.days.ago }
      let(:done_closed_10_days_ago) { create :need_with_matches }
      let(:done_no_help_closed_10_days_ago) { create :need_with_matches }
      let(:done_not_reachable_closed_10_days_ago) { create :need_with_matches }
      let(:taking_care_closed_10_days_ago) { create :need_with_matches }
      let(:not_for_me_10_days_ago) { create :need_with_matches }
      let(:closed_20_days_ago) { create :need_with_matches }

      before do
        travel_to(10.days.ago) { done_closed_10_days_ago.reload.matches.first.update(status: :done) }
        travel_to(10.days.ago) { done_no_help_closed_10_days_ago.reload.matches.first.update(status: :done_no_help) }
        travel_to(10.days.ago) { done_not_reachable_closed_10_days_ago.reload.matches.first.update(status: :done_not_reachable) }
        travel_to(10.days.ago) { taking_care_closed_10_days_ago.reload.matches.first.update(status: :taking_care) }
        travel_to(10.days.ago) { not_for_me_10_days_ago.reload.matches.first.update(status: :not_for_me) }
        travel_to(20.days.ago) { closed_20_days_ago.reload.matches.first.update(status: :done) }
      end

      it { is_expected.to contain_exactly(done_closed_10_days_ago, done_no_help_closed_10_days_ago) }
    end

    describe 'by_subject' do
      let(:a_subject) { create :subject }
      let(:need_1) { create :need_with_matches, subject: a_subject }
      let(:need_2) { create :need_with_matches }

      subject { described_class.by_subject(a_subject.id) }

      context 'with no match' do
        it { is_expected.to contain_exactly(need_1) }
      end
    end

    describe 'created_since' do
      let(:date1) { Time.zone.now.strftime('%Y-%m-%d') }
      let(:date2) { 2.days.ago.strftime('%Y-%m-%d') }
      let(:date3) { 3.days.ago.strftime('%Y-%m-%d') }
      let!(:need_1) { create :need_with_matches, created_at: date1 }
      let!(:need_2) { create :need_with_matches, created_at: date2 }
      let!(:need_3) { create :need_with_matches, created_at: date3 }

      subject { described_class.created_since(date2) }

      it { is_expected.to contain_exactly(need_1, need_2) }
    end

    describe 'created_until' do
      let(:date1) { Time.zone.now.strftime('%Y-%m-%d') }
      let(:date2) { 2.days.ago.strftime('%Y-%m-%d') }
      let(:date3) { 3.days.ago.strftime('%Y-%m-%d') }
      let!(:need_1) { create :need_with_matches, created_at: date1 }
      let!(:need_2) { create :need_with_matches, created_at: date2 }
      let!(:need_3) { create :need_with_matches, created_at: date3 }

      subject { described_class.created_until(date2) }

      it { is_expected.to contain_exactly(need_2, need_3) }
    end
  end

  describe 'no_activity' do
    let(:need) { create :need_with_matches }
    let(:date1) { 2.months.ago }
    let(:old_need) { travel_to(date1) { create :need_with_matches } }

    it do
      expect(need.no_activity?).to be false
      expect(old_need.no_activity?).to be true
      expect(described_class.no_activity).to contain_exactly(old_need)

      travel_to(2.months.from_now) do
        expect(need.no_activity?).to be true
        expect(old_need.no_activity?).to be true
        expect(described_class.no_activity).to contain_exactly(need, old_need)
      end
    end
  end

  describe 'touch diagnosis' do
    let(:date1) { Time.zone.now.beginning_of_day }
    let(:date2) { date1 + 1.minute }
    let(:date3) { date1 + 2.minutes }

    let(:diagnosis) { travel_to(date1) { create :diagnosis } }

    before { diagnosis }

    subject { diagnosis.reload.updated_at }

    context 'when a need is added to a diagnosis' do
      let(:need) { travel_to(date3) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { diagnosis.needs = [need] }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a need is removed from a diagnosis' do
      let(:need) { travel_to(date1) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { need.destroy }
      end

      it { is_expected.to eq date3 }
    end

    context 'when a need is updated' do
      let(:need) { travel_to(date1) { create :need, diagnosis: diagnosis } }

      before do
        need
        travel_to(date3) { need.update(content: 'New content') }
      end

      it { is_expected.to match_array date3 }
    end
  end

  describe 'paniers relance' do
    describe 'besoins à relancer (J+9)' do
      # - besoins restés sans réponse (=sans positionnement, personne a cliqué sur les boutons "je prends en charge" ou "je refuse") à plus 7 jours après les mises en relation ;
      # - besoins avec une mise en relation clôturée par « pas d’aide disponible » et « non joignable » ET pour lesquels des experts n’ont toujours pas répondu à plus de 7 jours.

      describe 'contraintes de délais' do
        # DELAIS
        # - besoin créé il y a 08 jours, sans positionnement        ko
        # - besoin créé il y a 09 jours, sans positionnement        ok
        # - besoin créé il y a 20 jours, sans positionnement        ok
        # - besoin créé il y a 21 jours, sans positionnement        ko
        # - besoin créé il y a 10 jrs, ms MER pas envoyée           ko
        # - besoin créé il y a 15 jrs, ms MER envoyé il y a 8 jrs   ko
        # - besoin créé il y a 21 jrs, ms MER envoyé il y a 10 jrs  ok

        let(:reference_date) { Time.zone.now.beginning_of_day }

        let!(:need1) { travel_to(reference_date - 8.days)  { create :need_with_matches } }
        let!(:need2) { travel_to(reference_date - 9.days)  { create :need_with_matches } }
        let!(:need3) { travel_to(reference_date - 20.days) { create :need_with_matches } }
        let!(:need4) { travel_to(reference_date - 21.days) { create :need_with_matches } }
        let!(:need5) { travel_to(reference_date - 8.days)  { create :need_with_unsent_matches } }
        let!(:need6) { travel_to(reference_date - 15.days) { create :need_with_unsent_matches } }
        let!(:need7) { travel_to(reference_date - 21.days) { create :need_with_unsent_matches } }

        before do
          need6.matches.update_all(sent_at: reference_date - 8.days)
          need7.matches.update_all(sent_at: reference_date - 10.days)
        end

        it 'retourne les besoins dans la bonne période' do
          expect(described_class.reminders_to(:poke)).to contain_exactly(need2, need3, need7)
        end
      end

      describe 'contraintes de Reminder Action' do
        # - besoin créé il y a 09 jours, sans positionnement, pas marqué "traité", avec commentaire  ok
        # - besoin créé il y a 09 jours, sans positionnement, marqué "traité"                        ko
        # - besoin créé il y a 09 jours, avec positionnement, pas marqué "traité"                    ko
        # - besoin créé il y a 09 jours, avec positionnement, marqué "traité"                        ko

        let(:poke_days_ago) { Time.zone.now.beginning_of_day - 9.days }

        let!(:need1) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:feedback1) { create :feedback, :for_need, feedbackable: need1 }
        let!(:need2) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:reminders_action2) { create :reminders_action, category: :poke, need: need2 }
        let!(:need3) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:need3_match) { travel_to(poke_days_ago) { create :match, need: need3, status: :taking_care } }
        let!(:need4) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:need4_match) { travel_to(poke_days_ago) { create :match, need: need4, status: :taking_care } }
        let!(:reminders_action4) { create :reminders_action, category: :poke, need: need4 }

        it 'retourne les besoins sans Reminder Action' do
          expect(described_class.reminders_to(:poke)).to contain_exactly(need1)
        end
      end

      describe 'contraintes de relations' do
        # - besoin créé il y a 09 jours, avec 1 positionnement « refusé », et autres MER sans réponse           ok
        # - besoin créé il y a 09 jours, avec 1 cloture « pas d’aide disponible », et autres MER sans réponse   ko
        # - besoin créé il y a 09 jours, avec 1 cloture « injoignable », et autres MER sans réponse             ko
        # - besoin créé il y a 09 jours, avec 1 commentaire                                                     ok
        # - besoin créé il y a 09 jours, sans positionnement                                                    ok

        let(:poke_days_ago) { Time.zone.now.beginning_of_day - 9.days }

        let!(:need1) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:need1_match) { travel_to(poke_days_ago) { create :match, need: need1, status: :not_for_me } }
        let!(:need2) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:need2_match) { travel_to(poke_days_ago) { create :match, need: need2, status: :done_no_help } }
        let!(:need3) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:need3_match) { travel_to(poke_days_ago) { create :match, need: need3, status: :done_not_reachable } }
        let!(:need4) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:feedback4) { create :feedback, :for_need, feedbackable: need4 }
        let!(:need5) { travel_to(poke_days_ago) { create :need_with_matches } }
        let!(:need5_match) { travel_to(poke_days_ago) { create :match, need: need5, status: :quo } }

        it 'retourne les besoins avec certaines relations' do
          expect(described_class.reminders_to(:poke)).to contain_exactly(need1, need4, need5)
        end
      end
    end

    describe 'besoins qui vont être abandonné (j+21)' do
      # - besoins restés sans réponse à plus 21 jours après les mises en relation ;
      # - besoins avec une mise en relation clôturée par « pas d’aide disponible » et « non joignable »
      #   ET pour lesquels des experts n’ont toujours pas répondu à plus de 21 jours.

      describe 'contraintes de délais' do
        # - besoin créé il y a 20 jours, sans positionnement     ko
        # - besoin créé il y a 21 jours, sans positionnement     ok
        # - besoin créé il y a 30 jours, sans positionnement     ok

        let(:reference_date) { Time.zone.now.beginning_of_day }

        let!(:need1) { travel_to(reference_date - 20.days) { create :need_with_matches } }
        let!(:need2) { travel_to(reference_date - 21.days) { create :need_with_matches } }
        let!(:need3) { travel_to(reference_date - 30.days) { create :need_with_matches } }

        it 'retourne les besoins dans la bonne période' do
          expect(described_class.reminders_to(:last_chance)).to contain_exactly(need2, need3)
        end
      end

      describe 'contraintes de Reminder Action' do
        # - besoin créé il y a 21 jours, sans positionnement, pas marqué "traité J+21"              ok
        # - besoin créé il y a 21 jours, sans positionnement, que marqué "traité J+09"              ok
        # - besoin créé il y a 21 jours, sans positionnement, marqué "traité J+21"                  ko
        # - besoin créé il y a 21 jours, avec positionnement, pas marqué "traité J+21"              ko
        # - besoin créé il y a 21 jours, avec positionnement, marqué "traité J+21"                  ko
        # - besoin créé il y a 21 jours, sans positionnement, marqué "traité J+09" et "traité J+21" ko

        let(:twenty_one_days_ago) { Time.zone.now.beginning_of_day - 21.days }
        let!(:need1) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let(:need2) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:reminders_action2) { create :reminders_action, category: :poke, need: need2 }
        let(:need3) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:reminders_action3) { create :reminders_action, category: :last_chance, need: need3 }
        let!(:need4) { travel_to(twenty_one_days_ago) { create :need, matches: [create(:match, status: :taking_care)] } }
        let(:need5) { travel_to(twenty_one_days_ago) { create :need, matches: [create(:match, status: :taking_care)] } }
        let!(:reminders_action5) { create :reminders_action, category: :last_chance, need: need5 }
        let(:need6) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:reminders_action6) { create :reminders_action, category: :poke, need: need6 }
        let!(:reminders_action7) { create :reminders_action, category: :last_chance, need: need6 }

        it 'retourne les besoins sans Reminder Action' do
          expect(described_class.reminders_to(:last_chance)).to contain_exactly(need1, need2)
        end
      end

      describe 'contraintes de status' do
        # - besoin créé il y a 21 jours, avec 1 positionnement « refusé », et autres MER sans réponse           ko
        # - besoin créé il y a 21 jours, avec 1 cloture « pas d’aide disponible », et autres MER sans réponse   ko
        # - besoin créé il y a 21 jours, avec 1 cloture « injoignable », et autres MER sans réponse             ko
        # - besoin créé il y a 21 jours, sans positionnement                                                    ok

        let(:twenty_one_days_ago) { Time.zone.now.beginning_of_day - 21.days }

        let!(:need1) { travel_to(twenty_one_days_ago) { create :need } }
        let!(:need1_match) { travel_to(twenty_one_days_ago) { create :match, need: need1, status: :not_for_me } }
        let!(:need2) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:need2_match) { travel_to(twenty_one_days_ago) { create :match, need: need2, status: :done_no_help } }
        let!(:need3) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:need3_match) { travel_to(twenty_one_days_ago) { create :match, need: need3, status: :done_not_reachable } }
        let!(:need4) { travel_to(twenty_one_days_ago) { create :need_with_matches } }
        let!(:need4_match) { travel_to(twenty_one_days_ago) { create :match, need: need4, status: :quo } }

        it 'retourne les besoins avec certains status' do
          expect(described_class.reminders_to(:last_chance)).to contain_exactly(need4)
        end
      end
    end

    describe 'in_reminders_range' do
      let(:date1) { Time.zone.now.beginning_of_day }
      let(:date2) { date1 - 11.days }
      let(:date3) { date1 - 21.days }
      let!(:new_need) { travel_to(date1) { create :need_with_matches } }
      let!(:mid_need) { travel_to(date2) { create :need_with_matches } }
      let!(:old_need) { travel_to(date3) { create :need_with_matches } }

      subject { described_class.in_reminders_range(:poke) }

      it 'expect to have needs between 10 and 30 days' do
        is_expected.to contain_exactly(mid_need)
      end
    end
  end

  describe 'veille' do
    describe 'with_filtered_matches_quo' do
      let!(:need_quo_recent) { create :need, status: :done, matches: [ create(:match, status: :done), create(:match, status: :quo)] }
      let!(:need_quo_expired) { create :need, status: :done, matches: [ create(:match, status: :done, sent_at: 46.days.ago), create(:match, status: :quo, sent_at: 46.days.ago)] }
      let!(:need_not_sent) { create :need_with_unsent_matches }

      let!(:expert_relance) { create :expert_with_users, :with_reminders_register, job: 'expert_with_one_quo_match_1' }
      let!(:need_in_relance_expert) { create :need, status: :quo, matches: [ create(:match, status: :quo, sent_at: 30.days.ago), create(:match, status: :quo, sent_at: 30.days.ago, expert: expert_relance)] }
      let!(:need_in_relance_besoin) { create :need, status: :quo, matches: [ create(:match, status: :quo, sent_at: 30.days.ago), create(:match, status: :quo, sent_at: 30.days.ago)] }
      let!(:need_with_quo_match) { create :need, status: :done, matches: [ create(:match, status: :quo, sent_at: 30.days.ago), create(:match, status: :done, sent_at: 30.days.ago)] }
      let!(:need_with_quo_match_seen) { create :need, status: :done, matches: [ create(:match, status: :quo, sent_at: 30.days.ago), create(:match, status: :done, sent_at: 30.days.ago)] }
      let!(:seen_action) { create :reminders_action, category: :quo_match, need: need_with_quo_match_seen }

      it 'filters only correct need' do
        expect(described_class.with_filtered_matches_quo).to contain_exactly(need_with_quo_match)
      end
    end

    describe 'starred' do
      let!(:unstar_need) { create :need, starred_at: nil }
      let!(:starred_need) { create :need, starred_at: Time.zone.now }
      let!(:starred_need_seen) { create :need, starred_at: Time.zone.now }
      let!(:seen_action) { create :reminders_action, category: :starred_need, need: starred_need_seen }

      it 'filters only correct need' do
        expect(described_class.starred).to contain_exactly(starred_need)
      end
    end
  end

  describe 'search' do
    let(:subject1) { create :subject, label: "sujet un" }
    let(:subject2) { create :subject, label: "sujet deux" }
    let(:diagnosis1) { create :diagnosis, company: create(:company, name: "Entreprise deux") }
    let(:contact1) { create :contact, full_name: "Jérôme Luciani" }
    let(:contact2) { create :contact, full_name: "Amina Jerome" }
    let(:need1) { create :need, content: "la la", visitee: contact1 }
    let(:need2) { create :need, content: "la lo", subject: subject2, visitee: contact2 }
    let(:need3) { create :need, content: "lo deux", subject: subject1 }
    let(:need4) { create :need, content: "li li", diagnosis: diagnosis1 }

    it 'searches content' do
      expect(described_class.omnisearch("la")).to contain_exactly(need1, need2)
    end

    it 'searches subject' do
      expect(described_class.omnisearch("sujet un")).to contain_exactly(need3)
    end

    it 'searches multiple fields' do
      expect(described_class.omnisearch("deux")).to contain_exactly(need2, need3, need4)
    end

    it 'searches with accent' do
      expect(described_class.omnisearch("jerome")).to contain_exactly(need1, need2)
    end
  end
end
