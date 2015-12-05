# RssApiTemplete

データ作成コマンド
'''
$ rails runner Tasks::Batch.parse

$ cd /var/www/nichannel/current
$ rails runner -e production Tasks::Batch.parse
'''

## AWS
作成時に参考にしたサイト

- http://qiita.com/Yama-to/items/1e1d889e6d5f7cc7f281

### 設定
password = いつもの
root_url = http://52.34.83.184
ssh -i Kento.pem ec2-user@52.34.83.184
ssh -i Kento.pem nichannel@52.34.83.184

### コマンドメモ
```
$ sudo su nichennale
$ sudo service mysqld restart
$ sudo service nginx restart

$ bundle exec cap production deploy
$ cap production deploy:update_cron
```

## エラーメモ

サーバー動いているか確認`ps -ef | grep unicorn | grep -v grep`
`kill -QUIT tmp/pids/unicorn.pid`サーバーの再起動
動いてるのに`not found`が出る=>config.ruにサブドメインを設定している可能性がある
`tail -f log/*`