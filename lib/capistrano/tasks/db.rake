namespace :db do

  desc 'Dump db on the production in dumps directory with current timestamp as a filename'
  task :dump do
    on roles(:app) do
      execute "PGPASSWORD=#{production_database_configs[:password]} pg_dump --host #{production_database_configs[:host]} --username #{production_database_configs[:username]} --verbose --clean --no-owner --no-acl --format=c #{production_database_configs[:database]} > ~/dumps/#{Time.now.to_i}.dump"
    end
  end

  desc 'Fetch latest dump from dumps directory to production.dump'
  task :fetch do
    on roles(:app) do
      remote_file_name = "/home/ubuntu/dumps/#{capture('ls -t dumps | head -n1')}"
      local_file_name = "production.dump"
      download! remote_file_name, local_file_name
    end
  end

  desc 'Restore production.dump to local database'
  task :restore do
    run_locally do
      execute 'bundle exec rails db:drop'
      execute 'bundle exec rails db:create'
      execute "pg_restore --verbose --clean --no-acl --no-owner --host #{local_database_configs[:host]} --username #{local_database_configs[:username]} --dbname=#{local_database_configs[:database]} production.dump", raise_on_non_zero_exit: false
      execute 'RAILS_ENV=development bundle exec rails db:environment:set'
      execute 'rm production.dump'
      setting_up_production_database_to_local
    end
  end

  desc 'Fetch latest database dump and restore it to local database'
  task fetch_restore: [:fetch, :restore] do
  end

  # Some database entries that should be removed from local database after production dump
  def setting_up_production_database_to_local
    execute 'bundle exec rails runner "WorkFlows::WorkFlow.destroy_all"'
  end

  def local_database_configs
    @local_database_configs ||= YAML.load_file('config/database.yml')['development'].symbolize_keys
  end

  def production_database_configs
    @production_database_configs ||= YAML.load_file('config/database.yml')['production'].symbolize_keys
  end

end

before :deploy, :'db:dump'
