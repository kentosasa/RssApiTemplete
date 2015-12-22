# config valid only for current version of Capistrano
lock '3.4.0'
set :rbenv_ruby,    '2.1.3'
set :application,   'dansikou'
set :repo_url,      'git@github.com:kentosasa/RssApiTemplete.git'
set :branch,        'dansikou'
set :deploy_to,     '/var/www/dansikou'
set :linked_dirs,   fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :keep_releases, 2
set :MECAB_PATH,    "/usr/lib64/libmecab.so.2"
set :default_env, {
    'MECAB_PATH' => '/usr/lib64/libmecab.so.2'
}
# set values for slackistrano deployment notifier
# set :slack_webhook,      'https://hooks.slack.com/services/T02B5F7S3/B0ATNSDB6/ERhof0moz0987uLtiXXXXXX'
# set :slack_icon_url,     'https://s3-ap-northeast-1.amazonaws.com/tomajax/images/tomato3_small.png'
# set :slack_username,     'Tomajax'
# set :slack_msg_starting, "#{ENV['USER'] || ENV['USERNAME']} による #{fetch :branch} ブランチの #{fetch :rails_env, 'production'} 環境へのデプロイが始まります。"
# set :slack_msg_finished, "#{ENV['USER'] || ENV['USERNAME']} による #{fetch :branch} ブランチの #{fetch :rails_env, 'production'} 環境へのデプロイが成功しました！！"
# set :slack_msg_failed,   "#{ENV['USER'] || ENV['USERNAME']} による #{fetch :branch} ブランチの #{fetch :rails_env, 'production'} 環境へのデプロイが失敗しました..."
namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end
  desc 'Create database'
  task :db_create do
    on roles(:db) do |host|
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end
  desc 'Run seed'
  task :seed do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:seed'
        end
      end
    end
  end
  desc "Update crontab with whenever"
  task :update_cron do
    on roles(:app) do
      with rails_env: :production do
        within current_path do
          execute :bundle, :exec, "whenever --update-crontab"
        end
      end
    end
  end
  after :publishing, :restart
  after :restart,    :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do; end
  end
  after :finished,   :cleanup
end