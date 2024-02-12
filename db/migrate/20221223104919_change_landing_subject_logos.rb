class ChangeLandingSubjectLogos < ActiveRecord::Migration[7.0]
  def up
    change_column_default :institutions, :display_logo, from: false, to: true
    remove_column :institutions_subjects, :optional, :boolean, default: false

    # Recruter un ou plusieurs salariés
    if Institution.find_by(slug: 'cci').present?
      InstitutionSubject.where(subject_id: 44).joins(:institution).merge(Institution.opco).update_all(description: "Les conseillers des OPCO vous aident sur le recrutement en alternance selon votre secteur d'activité.")
      Institution.find_by(slug: 'apec').institutions_subjects.where(subject_id: 44).update_all(description: "Les conseillers de l'Apec vous aident sur le recrutement de compétences de cadres.")
      Institution.find_by(slug: 'cap-emploi').institutions_subjects.where(subject_id: 44).update_all(description: "Les conseillers de Cap emploi vous aident sur le recrutement de personnes en situation de handicap.")
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 44).update_all(description: "Les conseillers des CCI vous aident sur le recrutement en alternance en lien avec les centres de formation.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 44).update_all(description: "Les conseillers des CMA vous aident sur le recrutement en alternance en lien avec les centres de formation.")
      Institution.find_by(slug: 'pole_emploi').institutions_subjects.where(subject_id: 44).update_all(description: "Les conseillers de Pôle emploi vous aident sur le recrutement de tous profils.")

      # Accompagner et financer un projet de formation
      InstitutionSubject.where(subject_id: 45).joins(:institution).merge(Institution.opco).update_all(description: "Les conseillers des OPCO vous aident sur le financement de la formation de vos salariés selon votre secteur.")
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 45).update_all(description: "Les conseillers des CCI vous aident à former vos salariés ou en tant que dirigeant.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 45).update_all(description: "Les conseillers des CMA vous aident à former vos salariés ou en tant que dirigeant.")
      Institution.find_by(slug: 'pole_emploi').institutions_subjects.where(subject_id: 45).update_all(description: "Les conseillers de Pôle emploi vous aident sur la formation de futurs salariés pour leur prise de poste.")

      # Optimiser l'organisation du travail et la gestion des carrières
      InstitutionSubject.where(subject_id: 46).joins(:institution).merge(Institution.opco).update_all(description: "Les conseillers des OPCO vous aident sur la gestion des ressources humaines.")
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 46).update_all(description: "Les conseillers de la CCI vous aident sur la gestion des ressources humaines.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 46).update_all(description: "Les conseillers de la CMA vous aident sur la gestion des ressources humaines.")
      Institution.find_by(slug: 'dreets').institutions_subjects.where(subject_id: 46).update_all(description: "Les conseillers des DREETS vous aident à réaliser un diagnostic RH en enteprise.")
      Institution.find_by(slug: 'aract').institutions_subjects.where(subject_id: 46).update_all(description: "Les conseillers de l'ARACT vous aident à améliorer la performance des équipes par l'organisation du travail et la prévention des conflits.")

      # Inclure le handicap en entreprise
      Institution.find_by(slug: 'agefiph').institutions_subjects.where(subject_id: 171).update_all(description: "Les conseillers de l'AGEFIPH vous aident à inclure le handicap dans votre politique de ressources humaines.")
      Institution.find_by(slug: 'cap-emploi').institutions_subjects.where(subject_id: 171).update_all(description: "Les conseillers Cap emploi vous aident sur le recrutement et le maintien dans l'emploi d'une personne en situation de handicap.")

      # Gérer les départs en retraite
      Institution.find_by(slug: 'carsat').institutions_subjects.where(subject_id: 172).update_all(description: "Les conseillers de la CARSAT vous aident pour le départ en retraite d'un salarié ou en tant que dirigeant.")

      # Etre accompagné sur les questions de droit du travail
      Institution.find_by(slug: 'dreets').institutions_subjects.where(subject_id: 47).update_all(description: "Les conseillers des DREETS vous aident sur vos questions en droit du travail.")

      # S'informer sur l'activité partielle
      Institution.find_by(slug: 'dreets').institutions_subjects.where(subject_id: 123).update_all(description: "Les conseillers des DREETS vous aident sur la mise en place de l'activité partielle.")

      # Faire un point général sur sa stratégie, adapter son activité au nouveau contexte
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 46).update_all(description: "Les conseillers de la CCI vous aident à évaluer et questionner votre stratégie d'entreprise.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 46).update_all(description: "Les conseillers de la CMA vous aident à évaluer et questionner votre stratégie d'entreprise.")

      # Développer une nouvelle offre de produits ou de services
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 48).update_all(description: "Les conseillers de la CCI vous aident à développer à un nouveau produit ou service.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 48).update_all(description: "Les conseillers de la CMA vous aident à développer à un nouveau produit ou service.")
      Institution.find_by(slug: 'inpi').institutions_subjects.where(subject_id: 48).update_all(description: "Les conseillers de l'INPI vous aident à protéger votre création.")

      # Trouver de nouveaux clients et élargir son réseau professionnel
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 49).update_all(description: "Les conseillers de la CCI vous aident à trouver de nouveaux clients.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 49).update_all(description: "Les conseillers de la CMA vous aident à trouver de nouveaux clients.")

      # Conduire un projet à l'international
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 51).update_all(description: "Les conseillers de la CCI vous aident à développer votre projet à l'international.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 51).update_all(description: "Les conseillers de la CMA vous aident à développer votre projet à l'international.")
      Institution.find_by(slug: 'douanes').institutions_subjects.where(subject_id: 51).update_all(description: "Les conseillers des Douanes vous aident sur vos formalités aux frontières hors Union européenne, pour l'export et l'import de marchandises.")
      Institution.find_by(slug: 'dgfip').institutions_subjects.where(subject_id: 51).update_all(description: "Les conseillers de la DGFIP vous aident sur vos questions de fiscalité et de TVA à l'international.")
      Institution.find_by(slug: 'reseau-des-conseillers-du-commerce-exterieur').institutions_subjects.where(subject_id: 51).update_all(description: "Les conseillers du réseau du CCEF vous aident à rencontrer d'autres dirigeants présents à l'étranger pour bénéficier de leurs exépriences.")

      # Réaliser un projet foncier ou immobilier
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 53).update_all(description: "Les conseillers de la CCI vous aident à l'implantation ou au déménagement de votre entreprise.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 53).update_all(description: "Les conseillers de la CMA vous aident à l'implantation ou au déménagement de votre entreprise.")

      # Réaliser un projet d'innovation
      Institution.find_by(slug: 'bpifrance').institutions_subjects.where(subject_id: 54).update_all(description: "Les conseillers de Bpifrance vous aident à financer votre innovation.")
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 54).update_all(description: "Les conseillers de la CCI vous aident à développer votre projet d'innovation.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 54).update_all(description: "Les conseillers de la CMA vous aident à développer votre projet d'innovation.")
      Institution.find_by(slug: 'initiative-france').institutions_subjects.where(subject_id: 54).update_all(description: "Les conseillers du réseau Initiative vous aident à financer votre innivation.")
      Institution.find_by(slug: 'inpi').institutions_subjects.where(subject_id: 54).update_all(description: "Les conseillers de l'INPI vous aident à protéger votre innovation.")
      Institution.find_by(slug: 'dgfip').institutions_subjects.where(subject_id: 54).update_all(description: "Les conseillers de la DGFIP vous aident à comprendre les avantages fiscaux liés à l'innovation.")

      # Solliciter des avantages fiscaux et des réductions d'impôts
      Institution.find_by(slug: 'dgfip').institutions_subjects.where(subject_id: 170).update_all(description: "Les conseillers de la DGFIP vous aident à comprendre les avantages fiscaux pour certains investissements.")

      # Financer sa croissance et ses investissements
      Institution.find_by(slug: 'banque_de_france').institutions_subjects.where(subject_id: 55).update_all(description: "Les conseillers de la Banque de France vous accompagnent sur votre plan de financement.")
      Institution.find_by(slug: 'bpifrance').institutions_subjects.where(subject_id: 55).update_all(description: "Les conseillers de Bpifrance vous aident à financer vos nouveaux investissements.")
      Institution.find_by(slug: 'carsat').institutions_subjects.where(subject_id: 55).update_all(description: "Les conseillers de la CARSAT vous aident à financer vos investissements qui améliorent la prévention des risques professionnels.")
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 55).update_all(description: "Les conseillers de la CCI vous aident à identifier les financements possibles pour votre projet.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 55).update_all(description: "Les conseillers de la CMA vous aident à identifier les financements possibles pour votre projet.")
      Institution.find_by(slug: 'initiative-france').institutions_subjects.where(subject_id: 55).update_all(description: "Les conseillers du réseau Initiative vous aident à financer vos nouveaux investissements.")
      Institution.find_by(slug: 'adie').institutions_subjects.where(subject_id: 55).update_all(description: "Les conseillers de l'Adie vous aident à financer vos projets non soutenus par les banques.")

      # Faire un point sur sa situation économique et financière
      Institution.find_by(slug: 'banque_de_france').institutions_subjects.where(subject_id: 58).update_all(description: "Les conseillers de la Banque de France vous aident à faire un diagnostic de la situation financière de votre entreprise.")
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 58).update_all(description: "Les conseillers de la CCI vous aident à trouver des solutions financières.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 58).update_all(description: "Les conseillers de la CMA vous aident à trouver des solutions financières.")

      # Résoudre un problème de trésorerie, faire face à ses charges
      Institution.find_by(slug: 'banque_de_france').institutions_subjects.where(subject_id: 42).update_all(description: "Les conseillers de la Banque de France vous aident à faire un diagnostic de la situation financière de l'entreprise.")
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 42).update_all(description: "Les conseillers de la CCI vous aident à trouver des solutions financières.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 42).update_all(description: "Les conseillers de la CMA vous aident à trouver des solutions financières.")
      Institution.find_by(slug: 'dreets').institutions_subjects.where(subject_id: 42).update_all(description: "Les conseillers des Dreets recherchent des solutions financières pour les entreprises industrielles en difficultés.")
      Institution.find_by(slug: 'urssaf').institutions_subjects.where(subject_id: 42).update_all(description: "Les conseillers de l'URSSAF vous aident dans le réglement des cotisations sociales.")
      Institution.find_by(slug: 'dgfip').institutions_subjects.where(subject_id: 42).update_all(description: "Les conseillers de la DGFIP vous aident en prévention de difficultés plus grandes et dans le réglement de dettes fiscales.")

      # Résoudre un différend avec un partenaire ou un concurrent
      Institution.find_by(slug: 'banque_de_france').institutions_subjects.where(subject_id: 40).update_all(description: "Les conseillers de la Banque de France vous aident à établir une médiation avec votre banque.")
      Institution.find_by(slug: 'mediation-des-entreprises').institutions_subjects.where(subject_id: 40).update_all(description: "Les conseillers de Médiateur des entreprises vous aident à trouver une solution amiable avec une autre entreprise ou une structure publique.")

      # Répondre à mes obligations en matière de santé et de sécurité
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 107).update_all(description: "Les conseillers de la CCI vous aident à évaluer les risques professionnels pour votre document unique et vous informe sur les normes d'hygiène et de sécurité.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 107).update_all(description: "Les conseillers de la CMA vous aident à évaluer les risques professionnels pour votre document unique et vous informe sur les normes d'hygiène et de sécurité.")
      Institution.find_by(slug: 'carsat').institutions_subjects.where(subject_id: 107).update_all(description: "Les conseillers de la CARSAT vous aident dans la prévention des risques professionnels.")

      # Former ses salariés à la prévention des risques professionnels
      Institution.find_by(slug: 'carsat').institutions_subjects.where(subject_id: 108).update_all(description: "Les conseillers de la CARSAT vous aident à former vos salariés à la prévention des risques professionnels (TMS, risques chimiques...).")
      Institution.find_by(slug: 'aract').institutions_subjects.where(subject_id: 108).update_all(description: "Les conseillers de l'ARACT vous aident dans la prévention des risques psychosociaux.")

      # Améliorer les conditions de travail (management, télétravail…)
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 110).update_all(description: "Les conseillers de la CCI vous aident à réaliser un diagnostic des conditions de travail de vos salariés.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 110).update_all(description: "Les conseillers de la CMA vous aident à réaliser un diagnostic des conditions de travail de vos salariés.")
      Institution.find_by(slug: 'aract').institutions_subjects.where(subject_id: 110).update_all(description: "Les conseillers de l'ARACT vous aident à mettre en place des actions pour améliorer les conditions de travail de vos salariés.")
      Institution.find_by(slug: 'carsat').institutions_subjects.where(subject_id: 110).update_all(description: "Les conseillers de la CARSAT vous aident à financer vos investissements pour la prévention des risques professionnels.")

      # Gestion de l'énergie
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 114).update_all(description: "Les conseillers de la CCI vous aident à réaliser un diagnostic et un plan d'actions pour vos économies d'énergie.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 114).update_all(description: "Les conseillers de la CMA vous aident à réaliser un diagnostic et un plan d'actions pour vos économies d'énergie.")
      Institution.find_by(slug: 'bpifrance').institutions_subjects.where(subject_id: 114).update_all(description: "Les conseillers de BPI France vous aident à financer vos investissements pour améliorer la gestion de l'énergie.")

      # Traitement et valorisation des déchets
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 113).update_all(description: "Les conseillers de la CCI vous aident à réaliser un diagnostic et un plan d'actions pour vos économies d'énergie.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 113).update_all(description: "Les conseillers de la CMA vous aident à réaliser un diagnostic et un plan d'actions pour vos économies d'énergie.")
      Institution.find_by(slug: 'bpifrance').institutions_subjects.where(subject_id: 113).update_all(description: "Les conseillers de BPI France vous aident à financer vos investissements pour améliorer la gestion de l'énergie.")

      # Transport et mobilité
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 112).update_all(description: "Les conseillers de la CCI vous aident à réaliser un diagnostic et un plan d'actions pour la mobilité de vos salariés.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 112).update_all(description: "Les conseillers de la CMA vous aident à réaliser un diagnostic et un plan d'actions pour la mobilité de vos salariés.")
      Institution.find_by(slug: 'bpifrance').institutions_subjects.where(subject_id: 112).update_all(description: "Les conseillers de BPI France vous aident à financer vos investissements pour améliorer la mobilité de vos salariés.")

      # Gestion de l'eau
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 116).update_all(description: "Les conseillers de la CCI vous aident à réaliser un diagnostic et un plan d'actions pour vos économies d'eau.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 116).update_all(description: "Les conseillers de la CMA vous aident à réaliser un diagnostic et un plan d'actions pour vos économies d'eau.")
      Institution.find_by(slug: 'bpifrance').institutions_subjects.where(subject_id: 116).update_all(description: "Les conseillers de BPI France vous aident à financer vos investissements pour améliorer la gestion de l'eau.")

      # Démarche générale de transition écologique (stratégie, éco-conception, labels)
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 115).update_all(description: "Les conseillers de la CCI vous accompagnent dans votre projet de transition grâce à leur expertise.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 115).update_all(description: "Les conseillers de la CMA vous accompagnent dans votre projet de transition grâce à leur expertise.")
      Institution.find_by(slug: 'bpifrance').institutions_subjects.where(subject_id: 115).update_all(description: "Les conseillers de BPI France vous aident à financer vos investissements dans le cadre de votre projet de transition.")
      Institution.find_by(slug: 'aract').institutions_subjects.where(subject_id: 115).update_all(description: "Les conseillers de l'ARACT vous aident à évaluer les conséquences de votre projet de transition sur l'organisation du travail des équipes.")

      # Bilan et stratégie RSE
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 137).update_all(description: "Les conseillers de la CCI vous aident à réaliser un diagnostic et un plan d'actions pour votre stratégie RSE.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 137).update_all(description: "Les conseillers de la CMA vous aident à réaliser un diagnostic et un plan d'actions pour votre stratégie RSE.")
      Institution.find_by(slug: 'aract').institutions_subjects.where(subject_id: 137).update_all(description: "Les conseillers de l'ARACT vous aident à travailler un axe de la RSE : améliorer les conditions de travail de vos équipes.")
      Institution.find_by(slug: 'agefiph').institutions_subjects.where(subject_id: 137).update_all(description: "Les conseillers de l'AGEFIPH vous aident à travailler un axe de la RSE : bien inclure le handicap de vos équipes.")

      # Céder son entreprise
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 57).update_all(description: "Les conseillers de la CCI vous accompagnent dans toutes les étapes pour céder votre entreprise.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 57).update_all(description: "Les conseillers de la CMA vous accompagnent dans toutes les étapes pour céder votre entreprise.")

      # Reprendre une entreprise
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 119).update_all(description: "Les conseillers de la CCI vous aident à trouver une entreprise à reprendre et dans les étapes de la reprise.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 119).update_all(description: "Les conseillers de la CMA vous aident à trouver une entreprise à reprendre et dans les étapes de la reprise.")
      Institution.find_by(slug: 'initiative-france').institutions_subjects.where(subject_id: 119).update_all(description: "Les conseillers du réseau Initiative vous aident à financer la reprise d'une entreprise déjà identifiée.")

      # Vendre sur internet
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 52).update_all(description: "Les conseillers de la CCI vous aident à vendre sur internet.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 52).update_all(description: "Les conseillers de la CMA vous aident à vendre sur internet.")

      # Améliorer sa visibilité sur internet
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 120).update_all(description: "Les conseillers de la CCI vous aident à améliorer votre visibilité sur internet.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 120).update_all(description: "Les conseillers de la CMA vous aident à améliorer votre visibilité sur internet.")

      # Protéger ses données
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 121).update_all(description: "Les conseillers de la CCI vous aident à protéger vos données et à vous conformer à la réglementation.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 121).update_all(description: "Les conseillers de la CMA vous aident à protéger vos données et à vous conformer à la réglementation.")

      # Modifier ou compléter mes formalités d'entreprise
      Institution.find_by(slug: 'cci').institutions_subjects.where(subject_id: 105).update_all(description: "Les conseillers de la CCI vous aident à accomplir une formalité pour votre entreprise.")
      Institution.find_by(slug: 'cma').institutions_subjects.where(subject_id: 105).update_all(description: "Les conseillers de la CMA vous aident à accomplir une formalité pour votre entreprise.")

      # Déclaration d'activité des organismes de formation
      Institution.find_by(slug: 'dreets').institutions_subjects.where(subject_id: 109).update_all(description: "Les conseillers des DREETS vous aident à accomplir vos formalités pour devenir un organisme de formation.")

      # S'informer sur l'agrément « Entreprise solidaire d'utilité sociale » et ses avantages
      Institution.find_by(slug: 'dreets').institutions_subjects.where(subject_id: 122).update_all(description: "Les conseillers des DREETS vous aident à accomplir vos formalités pour obtenir l'agrément ESUS.")

      # Faire une autre demande
      Institution.find_by(slug: 'equipe_place_des_entreprises').institutions_subjects.where(subject_id: 59).update_all(description: "L'équipe Place des Entreprises va rechercher les conseillers compétents pour vous aider sur votre demande spécifique.")

      drop_table :landing_subjects_logos
    end
  end

  def down
    change_column_default :institutions, :display_logo, from: true, to: false
    add_column :institutions_subjects, :optional, :boolean, default: false

    ## Modification schema institution <-> landing_subject
    create_table :landing_subjects_logos do |t|
      t.belongs_to :logo
      t.belongs_to :landing_subject
    end
  end
end
