## Documentation

* ➡ [Setup (en)](01-setup.md)
* [Development (en)](02-development.md)
* [Deployment (en)](03-deployment.md)
* [Architecture (fr)](04-architecture.md)

# Setup a development environment

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

8. You can now start the web server and the jobs task.

        $ gem install foreman
        $ foreman start --procfile=Procfile.dev

    Website is now [running locally](http://localhost:3000)!

## SSL on localhost

To run locally using https, you’ll need specify a certificate and a key. The easiest is to use [mkcert](https://github.com/FiloSottile/mkcert).

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

---

Next: [Development](02-development.md)
