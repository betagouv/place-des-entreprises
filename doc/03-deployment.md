## Documentation

* [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* ➡ [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)

# Deployment

## Domain name

The `beta.gouv.fr` is registered on OVH by the DINUM, the `place-des-entreprises` subdomain is delegated to the team on AlwaysData. This allows us to manage TXT records ourselves and to add additional sub-subdomains. Contact the developer team to access the AlwaysData account.

## Branches and setup

Conseillers-entreprises.service-public.fr is deployed on [Scalingo](http://doc.scalingo.com/languages/ruby/getting-started-with-rails/), with two distinct environment, `reso-staging` and `reso-production.` (Reso is an old name of the project.)

* `reso-staging` is served at https://reso-staging.scalingo.io.
* `reso-production` is the actual https://conseillers-entreprises.service-public.fr

There are GitHub to Scalingo hooks setup for auto-deployment:
* The `main` branch is automatically deployed to the `reso-staging` env.
* The `production` branch is automatically deployed to the `reso-production` env.

Additionally, a `postdeploy` hook [is setup in the Procfile](https://doc.scalingo.com/platform/app/postdeploy-hook#applying-migrations) so that Rails migrations are run automatically.

In case of emergency, you can always run the rails console in production using the `scalingo` command line tool.

    $ scalingo -a reso-staging run rails c
    $ scalingo -a reso-production run rails c

## HSTS

HTTP Strict Transport Security is enabled in the app config (`config.force_ssl = true`) ; it’s disabled in the Scalingo settings, otherwise it duplicates the value in the header, which is invalid. Although browsers seem to tolerate it, security checks like [Mozilla Observatory](https://observatory.mozilla.org/analyze/conseillers-entreprises.service-public.fr) complain about it.

## Release

Use `rake push_to_production` to review the changes before pushing to production:

```
$ rake push_to_production
Updating main and production…
Last production commit is ebe7d79c4149c3ae64af917e0ccd09bb7c473cc8
About to merge 5 PRs and push to production:
🚀
* [#718](https://github.com/betagouv/place-des-entreprises/pull/718) display created_at date instead of visit date
* [#720](https://github.com/betagouv/place-des-entreprises/pull/720) Bump rack from 2.0.7 to 2.0.8
* [#714](https://github.com/betagouv/place-des-entreprises/pull/714) Do not cc everyone in UserMailer#match_feedback
* [#710](https://github.com/betagouv/place-des-entreprises/pull/710) Send a distinct email to the advisor when sending notifications
* [#713](https://github.com/betagouv/place-des-entreprises/pull/713) Redesign email css
Proceed?
```

Make sure these are the changes you expect to push to production.
* there may be substantial changes that require deeper testing;
* it’s ok to push small changes often;
* some changes may require a new environment variable to be defined, or some data might be manually migrated;
* let the team know about the impending release on the team discussion interface.

```
y
Basculement sur la branche 'production'
Done!
```

## Rollback

Reverting a deployment (rollback) is as easy as releasing:
* `git revert` the commit(s), or the merge commit(s) that need to be rolled back
* setup a new pull request with these reverts
* push to production as usual.

---

Next: [Architecture](04-architecture.md)
