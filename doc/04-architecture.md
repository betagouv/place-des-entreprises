## Documentation

* [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* [Deployment (en)](03-deployment.md)
* ➡ [Architecture (fr)](04-architecture.md)

# Conseillers-Entreprises - Architecture générale

Contrairement au reste de la documentation, ce chapitre est rédigé en français. Il s’adresse non seulement aux nouveaux membres rejoignant l’équipe, mais aussi aux administrations et services publics partenaires qui souhaiteraient mieux comprendre le fonctionnement de Conseillers-Entreprises.

## Types d’utilisateurs

Conseillers-Entreprises s’adresse a plusieurs classes d’utilisateurs :
1. En premier lieu, les entrepreneurs qui font appel au service via le formulaire en ligne. Ce sont les cibles premières du service.
2. En second lieu, les agents des services publics et parapublics enregistrés sur Conseillers-Entreprises. Il disposent d’un compte grâce auquel il peuvent se connecter et voir les demandes des entreprises qui ont besoin de leur aide.
3. Enfin, les membres de l’équipe Conseillers-Entreprises, qui ont un double rôle:
    * l’administration des comptes utilisateurs des agents,
    * et le suivi des mises en relation entre les entrepreneurs et les agents.

## Données

### Entrepreneurs
Les entrepreneurs, quand ils déposent une sollicitation sur `https://conseillers-entreprises.service-public.fr` fournissent ces informations :
* Informations de contact: prénom et nom, adresse email, téléphone ;
* Identitié de l’entreprise: numéro SIRET ;
* Sujet de la demande, sélectionné parmi plusieurs catégories et sous-catégories ;
* Description en texte libre: selon le sujet, une aide en ligne conseille automatiquement d’y préciser certains éléments, comme l’activité de l’entreprise, le montant de l’aide demandée, etc.

Une fois la sollicitation de l’entrepreneur reçue et validée, les informations de la société sont automatiquement récupérées depuis les bases administratives `entreprise.data.gouv.fr` et `API entreprise`.
* Données publiques de l’entreprise : raison sociale, forme juridique, tranche d’effectif, capital social, code NAF, adresse, IDCC ;
* Données sur les gérants : nom et fonction ;

Cette liste n’est pas exhaustive: d’autres informations disponibles dans les bases administratives sont appelées à être utilisées. Ces informations vont servir à sélectionner automatiquement les agents partenaires les plus susceptibles de venir à l’aide de l’entreprise. En particulier, l’adresse de l’établissement permet de choisir, par exemple, la bonne agence Pôle-Emploi.

### Agents publics et parapublics

De l’autre côté, on trouve donc les informations des agents recensées auprès des partenaires. Elles sont fournies par les organismes partenaires et ajoutées à la main par l’équipe en charge de Conseillers-Entreprises et tenues à jour au fil des échanges avec les partenaires. C’est en fait une grande partie de notre travail. Cet « annuaire » comporte notamment :
* Les coordonnées professionelles des agents : nom, fonction, email et téléphone de contact ;
* Leurs champs de compétence, classée selon les mêmes sujets et catégories que les besoins des entreprises,
* Leur zone géographique d’intervention, à la commune près.

## Volumétrie et contraintes


* Nous recensons environ 10 000 agents de 40 institutions partenaires (Septembre 2023)
* Nous recevons et transmettons plus de 2000 besoins d’entreprise par mois ; chaque besoin est transmis en général à deux ou trois agents.

Les statistiques publiques sont disponibles en temps réel [sur notre page /stats](https://conseillers-entreprises.service-public.fr/stats).

## Modèle de données

Le diagramme du [modèle de données](domain_model.pdf) est tenu à jour automatiquement à mesure des évolutions du code. Les principales classes sont:

* `User` : le compte utilisateur d’un agent enregistré sur le site ;
* `Expert` : un agent, ou une équipe de plusieurs agents, compétents sur des sujets ;
* `Subject` : un domaine de compétence d’aides aux entreprises ;
* `Company` : une entreprise aidée, identifiée par un SIREN ;
* `Solicitation` : une demande déposée par un entrepreneur sur `conseillers-entreprises.service-public.fr` ;
* `Need` : un besoin identifié d’une entreprise, correspondant à un Sujet ;
* et enfin, `Match` : une mise en relation, sur un sujet donné, entre une entreprise et un agent.

## Architecture technique

### Pile logicielle

Conseillers-entreprises.service-public.fr est une application web écrite en [Ruby on Rails](https://rubyonrails.org), avec une base de données [PostgreSQL](https://www.postgresql.org). Elle est déployée en PAAS chez [Scalingo](https://scalingo.com/fr), et hébergé dans un datacenter [Outscale](https://fr.outscale.com).
* Ruby on Rails est un framework de développement parmi les plus utilisés au monde, entre autres au sein de la communauté betagouv. Cela garantit des mises à jours régulières, ainsi que des corrections de failles de sécurité; par ailleurs, cela nous permet de trouver assez facilement de nouveaux développeurs.
* PostgreSQL est un système de gestion de base de données performant et moderne, souvent associé à Ruby on Rails pour les applications de ce type.

### Développement

Le développement de Conseillers-Entreprises est organisé sur [github](https://github.com/betagouv/place-des-entreprises).
* Le code source est libre et ouvert, et publié sour license AGPL.
* Le développement se fait de façon transparente ; les _issues_ et _pull requests_ sont visibles par tout le monde.

L’app Ruby est développée principalement sous forme de « [monolithe](https://m.signalvnoise.com/the-majestic-monolith/) ». Il y a très peu de javascript. De manière générale, Conseillers-Entreprises est développée de façon _prudente_: nous utilisons, autant que possible, des technologies qui ont fait leur preuve, et qui sont mises à jour régulièrement.

Nous travaillons de façon agile, par sprints de deux semaines. Le développement logiciel est fait en concertation permanente avec les autres membres de l’équipe. Un aperçu des sujets en cours est visible [directement sur github](https://github.com/betagouv/place-des-entreprises/projects/1).

Nous utilisons les outils standard d’audit automatique de qualité de code ([rubocop](https://rubocop.org)) et de sécurité ([brakeman](https://brakemanscanner.org)). Par ailleurs, nous développons, en parallèle des fonctionnalités, les tests associés. Ces tests sont executés de façon automatique avant l’intégration de chaque changement dans le code. Nous utilisons [Circle-CI](https://circleci.com) pour faire tourner ces tests automatiques.

## Déploiement

Nous déployons régulièrement une nouvelle version de l‘application : plusieurs fois par semaine, voire plusieurs fois par jour, sans coupure de maintenance. Sauf exception, ces déploiements ne font pas l’objet de communication hors de l’équipe.

Par ailleurs, le code revu et accepté est déployé de façon automatique et continue sur une instance d’intégration, configurée de manière identique à l’instance de production.

### Hébergement

Conseillers-entreprises.service-public.fr est déployé sur la plateforme PAAS de [Scalingo](https://scalingo.com/fr), comme quelques autres startups d’États. Conseillers-entreprises.service-public.fr est sur la zone `osc-fr1` de Scalingo, hébergé dans un datacenter de Outscale, [situé en France](https://scalingo.com/fr/data-processing-agreement#pour-la-région-osc-fr1).

### Nom de domaine

Le domaine `service-public.fr` est géré par la DILA. La gestion du sous-domaine `conseillers-entreprises.` est déléguée à l’équipe en charge de Conseillers-Entreprises.

## Services externes

### Au sein de l’admistration

Conseillers-Entreprises récupère les données publiques des entreprises sur [annuaire-entreprises.data.gouv.fr](https://annuaire-entreprises.data.gouv.fr/), [entreprise.api.gouv.fr](https://entreprise.api.gouv.fr), l' [API de l'INSEE](https://api.insee.fr/catalogue) ou [registre-national-entreprises.inpi.fr](https://registre-national-entreprises.inpi.fr/api/), des plateformes maintenues par l'administration.

Nous utilisons aussi des outils propres à la communauté betagouv :
* [sentry.data.gouv.fr/betagouvfr/](https://sentry.data.gouv.fr/betagouvfr/) est un outil standard de monitoring de pannes logicielles; les erreurs et crashes de Conseillers-entreprises.service-public.fr, côté client comme serveur, y sont consignés.
* [stats.beta.gouv.fr](https://stats.beta.gouv.fr) est une instance [Matomo](https://matomo.org), un outil libre de mesure d’audience web,  [recommandé par la cnil](https://www.cnil.fr/fr/cookies-solutions-pour-les-outils-de-mesure-daudience).

### Services tiers

* [Brevo](https://www.brevo.com/) nous sert à envoyer les emails de confirmation, d’inscription, de notification… aux différents utilisateurs du service.
* [ipinfo.io](https://ipinfo.io/) est utilisé de façon annexe. La géolocalisation IP est utilisée uniquement pour afficher des logos spécifiques à la région de localisation des visiteurs.

### Contrôle des accès

Un journal de contrôle des accès aux différents services externes est tenu à jour, en particulier à l’arrivée et au départ de membres de l’équipe.
