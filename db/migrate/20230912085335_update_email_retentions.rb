class UpdateEmailRetentions < ActiveRecord::Migration[7.0]
  def change
    up_only do
      if Subject.where(id: 55).present?
        finance_projet = Subject.find(55)
        recruter = Subject.find(44)
        former = Subject.find(45)
        droit_travail = Subject.find(47)
        trouver_clients = Subject.find(49)
        visibilite_internet = Subject.find(120)
        international = Subject.find(51)
        conditions_travail = Subject.find(110)
        ecologie = Subject.find(115)
        gestion_energie = Subject.find(114)
        strategie_rse = Subject.find(137)
        projet_innovation = Subject.find(54)
        inclure_handicap = Subject.find(171)
        emails = [
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>financer un projet</strong>.</p><p>D’autres dirigeants cherchant comme vous à financer leur projet ont également utilisé ce service pour recruter et faire un point sur leur stratégie.</p>',
            subject: finance_projet,
          },
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>recruter</strong>.</p><p>D’autres dirigeants cherchant comme vous à recruter ont également utilisé ce service pour financer un nouveau projet et être conseillé en droit du travail.</p>',
            subject: recruter,
          },
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>trouver de nouveaux clients sur internet</strong>.</p><p>D’autres dirigeants cherchant comme vous à trouver de nouveaux clients sur internet ont également utilisé ce service pour améliorer leur visibilité sur internet et développer leur activité à l’international.</p>',
            subject: trouver_clients,
          },
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>améliorer votre visibilité sur internet</strong>.</p><p>D’autres dirigeants cherchant comme vous à améliorer leur visibilité sur internet ont également utilisé ce service pour trouver de nouveaux clients et développer leur activité à l’international.</p>',
            subject: visibilite_internet,
          },
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>développer votre activité à l’international</strong>.</p><p>D’autres dirigeants cherchant comme vous à développer leur activité à l’international ont également utilisé ce service pour améliorer leur visibilité sur internet et trouver de nouveaux clients.</p>',
            subject: international,
          },
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>améliorer les conditions de travail de vos salariés</strong>.</p><p>D’autres dirigeants cherchant comme vous à améliorer les conditions de travail de leurs salariés ont également utilisé ce service pour financer un nouveau projet et adapter leur activité à la transition écologique.</p>',
            subject: conditions_travail,
          },
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>améliorer votre gestion de l’énergie</strong>.</p><p>D’autres dirigeants cherchant comme vous à améliorer leur gestion de l’énergie ont également utilisé ce service pour financer un nouveau projet et développer leur stratégie RSE.</p>',
            subject: gestion_energie,
          },
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>réaliser un projet d’innovation</strong>.</p><p>D’autres dirigeants cherchant comme vous à réaliser un projet d’innovation ont également utilisé ce service pour former un ou plusieurs salariés et développer leur activité à l’international.</p>',
            subject: projet_innovation,
          },
          {
            first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public d’accompagnement des TPE-PME pour <strong>être conseillé en droit du travail</strong>.</p><p>D’autres dirigeants cherchant comme vous à être conseillé en droit du travail ont également utilisé ce service pour améliorer les conditions de travail de leurs salariés et inclure le handicap dans leur entreprise.</p>',
            subject: droit_travail,
          }
        ]
        emails.each do |maj_email|
          email = EmailRetention.find_by(subject_id: maj_email[:subject].id)
          p email
          if email.present?
            p email.first_paragraph
            p maj_email[:first_paragraph]
            email.update(first_paragraph: maj_email[:first_paragraph])
          end
          p '======================================'
        end
      end
    end
  end
end
