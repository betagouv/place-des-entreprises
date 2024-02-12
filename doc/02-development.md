## Documentation

* [Setup (en)](01-setup.md)
* ➡ [Development (en)](02-development.md)
* [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)

# Développement

## Langue

In consistency with the standard libraries and programming languages, the objects (methods, variables, classes…) created in the code are named in English:

> Examples : getCurrentYear(), var total = sum(1, 2).

However, domain-specific elements should keep their name, including in the code, without translation.

> Exemples : getRevenuFiscal(), var total = sum(chefDeFamille, conjoint).

## Pull requests and reviews

* Everything is done on feature branches and goes through pull requests;
* All pull requests must be reviewed by other members of the team, except the smallest changes that need to be urgently deployed;
* All pull requests must be rebased on `main` before being merged. This makes sure that the tip of the feature branch is in the same state as `main` will be after the merge;
* All pull requests must pass automated tests.

## Tests and lint

We’re using:
* `rspec` for unit and integration tests.
* `rubocop`, `haml-lint`, `i18n-tasks` for codestyle and quality
* `brakeman` for automated security analysis.

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

## Code coverage

If you want to update code coverage data, run :
```
COVERAGE=true bundle exec rspec
```


## Automated tests and Continuous integration

* Circle CI is hooked on github pull requests. It runs `rake test` and `rake lint`. The CI only runs for pull requests, not for all pushed branches.
* Code merged on `main` is automatically deployed on `reso-staging` (See [Deployment](03-deployment.md).)

The Circle CI account is shared with the other betagouv startups; it’s paid for by the DINUM.

## Testing Emails

Development emails are visible locally via [letter_opener_web](http://localhost:3000/letter_opener)
Staging emails are sent on [Mailtrap](https://mailtrap.io/) in order to test email notifications without sending them to the real users.

## Development data

You can import data in your local development database from remote staging database. See the [official documentation](https://doc.scalingo.com/platform/databases/access). You need to install the [Scalingo CLI](http://doc.scalingo.com/app/command-line-tool.html) first.

- `rake import_dump`:
 - `rake import_dump:dump` : dump data from scalingo
 - `rake import_dump:import` : drop local db and import
 - `rake import_dump:anonymize` : anonymize personal information fields

## Staging data

You can import production data in staging application, if you want to test features in almost real condition. You need to install the [Scalingo CLI](http://doc.scalingo.com/app/command-line-tool.html) first.

- `rake import_prod_to_staging`:
 - `rake import_dump:dump` : dump data from production db
 - `rake import_dump:import_to_staging` : import prod db in staging db

You may encounter dependencies problems. If so, you may have to change `/lib/tasks/import_prod_to_staging.rake` in order to drop a few problematic tables in staging before restoring database.

## API Conseillers-Entreprises

### Documentation

Conseillers-Entreprises API documentation makes use of swagger (`rswag` gem).
In order to generate documentation with automatic examples, run :

`rake rswag:specs:swaggerize SWAGGER_DRY_RUN=0`

---

Next: [Deployment](03-deployment.md)
