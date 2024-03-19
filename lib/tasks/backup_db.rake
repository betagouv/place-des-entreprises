namespace :backup_db do
  def setup_tunnel
    tunnel_command = 'scalingo -a reso-production db-tunnel SCALINGO_POSTGRESQL_URL'
    @tunnel_pid = fork{ exec tunnel_command }
  end

  task :dump do
    setup_tunnel
    sleep 2

    env = `scalingo -a reso-production env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]
    dbname = pg_url[/\/\/(.*):.*@/,1]

    sh "PGPASSWORD=#{pw} pg_dump --no-owner --no-acl #{dbname} > tmp/export.pgsql  -h localhost -p 10000 -U #{dbname}"

    Process.kill('QUIT', @tunnel_pid)
  end

  task save: :environment do
    file = File.open("tmp/export.pgsql")
    key = "db_backups/#{Time.now.to_i}"
    ActiveStorage::Blob.create_and_upload!(io: file, filename: key, key: key)
    File.delete(file)
  end

  task delete_old_files: :environment do
    blobs = ActiveStorage::Blob.where("key LIKE ?", "db_backups/" + "%").where("created_at < ?", 1.month.ago)
    blobs.map(&:purge)
  end

  task all: %i[dump save delete_old_files]
end

desc 'Dump db and save it on OVH'
task backup_db: %w[backup_db:all]
