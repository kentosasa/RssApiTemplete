# RssApiTemplete

データ作成コマンド
'''
$ rails runner Tasks::Batch.parse
'''

## AWS
作成時に参考にしたサイト

### 設定
password = いつもの
root_url = http://52.34.83.184

### コマンドメモ
```
$ sudo su nichennale
$ sudo service nginx restart
$ sudo service mysqld start

$ bundle exec cap production deploy
```