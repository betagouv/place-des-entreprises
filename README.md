# Place des Entreprises

Apporter l’ensemble des aides publiques aux entreprises qui en ont besoin. [place-des-entreprises.beta.gouv.fr](https://place-des-entreprises.beta.gouv.fr/)

Créé dans le contexte de [l’incubateur des startups d’état](https://beta.gouv.fr/).

## Getting started

1. Clone the repository.

        $ git clone git@github.com:betagouv/place-des-entreprises.git
        $ cd place-des-entreprises

2. Install Ruby using **rbenv**. See `.ruby-version` file to know which Ruby version is needed.

        $ brew install rbenv
        $ rbenv install

3. Install PostgreSQL and create a user if you don’t have any.

        $ brew install postgres

    Create a PostgreSQL user (replace `my_username` and `my_password`).

        $ psql -c "CREATE USER my_username WITH PASSWORD 'my_password';"

    Or:

        $ postgres createuser my_username

4. Create `config/database.yml` file from `config/database.yml.example`. Fill development and test sections in the latter with your PostgreSQL username and password.

        $ cp config/database.example.yml config/database.yml

5. Install project dependencies (gems) with bundler.

        $ gem install bundler
        $ bundle

6. Execute database configurations for development and test environments.

        $ rake db:create db:schema:load
        $ rake db:create db:schema:load RAILS_ENV=test
        $ rake parallel:create # for parallel

7. Create `.env` file from `.env.example`, and ask the team to fill it in.

        $ cp .env.example .env

8. You can now start a server.

        $ gem install foreman
        $ foreman start --procfile=Procfile.dev

    And yay! Place des Entreprises is now [running locally](http://localhost:3000)!

## Tests and lint

- `rake spec` : Unit and features tests
  - `bin/rspec`: … with spring
  - `RAILS_ENV=test rake parallel:spec`: parallel workers
  - `bin/parallel_rspec spec`: … with spring 
- `rake lint`:
  - `rake lint:rubocop` : ruby files code style
  - `rake lint:haml` : haml files code style 
  - `rake lint:i18n` : i18n missing/unused keys and formatting
  - `rake lint:brakeman` : static analysis security vulnerability 
- `rake lint_fix`: rubocop and i18n automatic codestyle fixes

## SSL on localhost

To run locally using https, you’ll need specify a certificate and a key. The easiest is to use [mkcert](https://github.com/FiloSottile/mkcert)

```
# install a root certificate on your machine
brew install mkcert
# generate a cert for localhost (and synonyms)
mkcert localhost 127.0.0.1 ::1 0.0.0.0
```

Don’t add the certificate and the key to git. You can put them in tmp. Then set `DEVELOPMENT_PUMA_SSL` to `1` and set the paths in `DEVELOPMENT_PUMA_SSL_KEY` in `DEVELOPMENT_PUMA_SSL_CERT`. It enables SSL for development. You can check that when runnings `rails s` it now should look like this:

```
* Min threads: 5, max threads: 5
* Environment: development
* Listening on ssl://0.0.0.0:3000?cert=...&key=...
```

There’s an additional step for Rubymine, because it overrides the settings in puma.rb and we need to over-override the _IP address_ and _port_ set in the Run Configuration window. The easiest seems to add this to _Server arguments_:
```
-b ssl://0.0.0.0:3000?cert=<path/to/cert>&key=<path/to/key>&verify_mode=none
```

## Browser compatibility

Supported browsers: recent versions of Firefox, Chrome, Safari, Edge or IE11.

Compatibility is tested with Browserstack.<br/>
[<img src="doc/browserstack-logo-600x315.png" width="200">](https://www.browserstack.com/)

## Development data

You can import data in your local development database from remote staging database. See the [official documentation](https://doc.scalingo.com/platform/databases/access), Make sure [Scalingo CLI](http://doc.scalingo.com/app/command-line-tool.html) is installed.

- `rake import_dump`:
 - `rake import_dump:dump` : dump data from scalingo 
 - `rake import_dump:import` : drop local db and import
 - `rake import_dump:anonymize` : anonymize personal information fields

## Emails

Development emails are visible locally via [letter_opener_web](http://localhost:3000/letter_opener) 
Staging emails are sent on [Mailtrap](https://mailtrap.io/) in order to test email notifications without sending them to the real users.

## Deployment

### HSTS

HTTP Strict Transport Security is enabled in the app config (`config.force_ssl = true`) ; it’s disabled in the Scalingo settings, otherwise it duplicates the value in the header, which is invalid. Although browsers seem to tolerate it, security checks like [Mozilla Observatory](https://observatory.mozilla.org/analyze/place-des-entreprises.beta.gouv.fr) complain about it.

### Branches and setup

Place des Entreprises is deployed on [Scalingo](http://doc.scalingo.com/languages/ruby/getting-started-with-rails/), with two distinct environment, ``reso-staging`` and `reso-production.

* `reso-staging` is served at https://reso-staging.scalingo.io.
* `reso-production` is the actual https://place-des-entreprises.beta.gouv.fr

GitHub->Scalingo hooks are setup for auto-deployment:
* The `master` branch is automatically deployed to the `reso-staging` env.
* The `production` branch is automatically deployed to the `reso-production` env.  

Additionally, a `postdeploy` hook [is setup in the Procfile](https://doc.scalingo.com/platform/app/postdeploy-hook#applying-migrations) so that Rails migrations are run automatically.  

In case of emergency, you can always run rails migrations manually using the `scalingo` command line tool.
    
    $ scalingo -a reso-staging run rails db:migrate
    $ scalingo -a reso-production run rails db:migrate 

### rake push_to_production

> Use `rake push_to_production` to review the changed before pushing to production:

```
$ rake push_to_production
Updating master and production…
Last production commit is ebe7d79c4149c3ae64af917e0ccd09bb7c473cc8
About to merge 5 PRs and push to production:
🚀 
* [#718](https://github.com/betagouv/place-des-entreprises/pull/718) display created_at date instead of visit date
* [#720](https://github.com/betagouv/place-des-entreprises/pull/720) Bump rack from 2.0.7 to 2.0.8
* [#714](https://github.com/betagouv/place-des-entreprises/pull/714) Do not cc everyone in UserMailer#match_feedback
* [#710](https://github.com/betagouv/place-des-entreprises/pull/710) Send a distinct email to the advisor when sending notifications
* [#713](https://github.com/betagouv/place-des-entreprises/pull/713) Redesign email css
Proceed?
y
Basculement sur la branche 'production'
Done!
```

### Domain name

The domain name is managed on AlwaysData, as well as the contact email adress. See the developer team to access the AlwaysData account. 

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our git and coding conventions, and the process for submitting pull requests to us.
