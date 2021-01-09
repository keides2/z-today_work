## z-today スクリプトの更新について

### 目的

- `CentOS7（xxx.xxx.xxx.xxx）`において、コマンドの定時実行などのスケジュール管理を行うために用いるコマンド`crontab`が管理する自動実行ファイル（`/var/spool/cron/vuls`）の保守を不要にする。

### 変更点

 - `crontab`が管理する自動実行ファイル（`/var/spool/cron/vuls`）では、自動実行スクリプト `z-today-mail.sh` に引数としてプロジェクト名を与えてこれを実行していたが、引数をやめ、指定のフォルダに存在するフォルダをプロジェクトとみなし、フォルダの数だけメールを送信する。

-  指定のフォルダとは、
   - `CentOS7`上では、
     - `/mnt/z/path/to/z-today/`
   - `Windows10`上では、
     - `Z:\path\to\z-today`

- この変更により、自動実行ファイル`/var/spool/cron/vuls`の保守が不要になる。

### 新プロジェクト適用手順

- 新しいプロジェクトを適用する場合は、このフォルダの下にプロジェクトの名前が付いたフォルダを置く。またプロジェクト名のフォルダの下には、処理が終わったファイルを移動するためのフォルダ`done`を作成しておく。

### 変更ファイル：`/var/spool/cron/vuls`

#### 変更前

```
00 15 * * 1-5 /home/vuls/z-today-mail.sh GPF > /var/log/vuls/z-today-mail.log 2>&1
```

- ※GPFが引数で、プロジェクトが増えるたびに、同様の行の追加が必要

#### 変更後

```
00 15 * * 1-5 /home/vuls/z-today-mail2.sh > /var/log/vuls/z-today-mail.log 2>&1
```

- ※プロジェクト共通のシェルスクリプトを作成したので、引数が不要になり、自動実行ファイル`vuls`の保守が不要

- ※シェルスクリプトは、`z-today-mail.sh`から、`z-today-mail2.sh`に変更した

### 変更ファイル：`/home/vuls/z-today-mail2.sh`

#### 変更前（/home/vuls/z-today-mail.sh）

- プロジェクト名を引数で受け取り、単一プロジェクトについてのみ処理

#### 変更後（/home/vuls/z-today-mail2.sh）

- プロジェクト名を引数で受け取ることをせず、上記フォルダを巡回し、存在するフォルダ名をプロジェクト名として処理
