namespace :import_dump do
  def setup_tunnel
    tunnel_command = 'scalingo -a reso-production db-tunnel SCALINGO_POSTGRESQL_URL'
    @tunnel_pid = fork{ exec tunnel_command }
  end

  def kill_tunnel
    Process.kill('QUIT', @tunnel_pid)
  end

  task :dump do
    setup_tunnel

    sleep 2

    env = `scalingo -a reso-production env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]
    dbname = pg_url[/\/\/(.*):.*@/,1]

    sh "PGPASSWORD=#{pw} pg_dump --no-owner --no-acl #{dbname} > tmp/export.pgsql  -h localhost -p 10000 -U #{dbname}"

    kill_tunnel
  end

  task :import do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    dbuser = YAML.load_file('config/database.yml', aliases: true).dig('development', 'username')

    sh "psql place-des-entreprises-development -f tmp/export.pgsql -U #{dbuser}"

    sh 'rm tmp/export.pgsql'

    Rake::Task['db:migrate'].invoke

    Rake::Task['db:environment:set'].invoke('RAILS_ENV=development')
  end

  task all: %i[dump import]
end

desc 'import anonymized production data in development db'
task import_anonymized: %w[import_dump:all anonymize:all db:seed]
