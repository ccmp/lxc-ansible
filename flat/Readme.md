# flat
## 変更点

* 全体で共通する部分を独立したPlaybookに切り出すのは見通しが悪くなるのでとりあえずやめる。
* rolesをそれぞれのサービスのディレクトリ以下に配置(lvs-web-dr廃止)
* テンプレートから設定ファイルを作成する処理をサービスのディレクトリから分離

## 設定ファイルについて
* 設定ファイルはconfigディレクトリ以下に基本的に完全なものを配置。
* それをコンテナのrootfs以下に配布する(LXCの設定はホストのLXCディレクトリに)
 * ただし、LXCの設定(LXCホストの/var/lib/lxc/<コンテナ名>/config)はデプロイ先で変更される部分があるのでコンテナのデプロイ時に作成する(テンプレートになっている)

## 設定の作成/変更/追加方法
* 基本的にconfig以下に必要なファイルを直接作成/変更/追加する(flatな構成)
* 設定の適用に必要な処理をPlaybookに記述する。

## 設定のテンプレートについて
* テンプレートを利用してconfig以下に設定を作成することも可能
* 直接編集とテンプレートを両方使う事も可能。

## roleについて
* deploy : デプロイ処理
* common_post.yml : 全体で共通の処理
* lvs_post.yml : LVSコンテナで共通の処理
* web_post.yml : Webコンテナで共通の処理
 * 上にも述べてある通りdeployおよびcommon_postの処理を別Playbookに切り出すのはやめている。

## serviceについて
* service1とservice2でPlaybookの構成や処理の手順がことなっている。

## service1
* 役割コンテナごとにグループを作成してそれを基準にPlaybookを実行する。 
 * lvs.ymlおよびweb.ymlがメインのPlaybook.
 * 個々のコンテナの処理はそれらのPlaybookに適宜includeする別Playbookに記述する。
### クラスタの作成
```
# ansible-playbook -i inventory/development service1/site.yml
```

## servive2
* 各コンテナごとにPlaybookを作成して実行
 * lvs1.yml,lvs2.yml,web1.yml,web2.ymlがメインのPlaybook.
 * 共通の処理もそれぞれのPlaybookに(同じものを)記述する。
 * 個々のコンテナの処理はそれらのPlaybookに直接記述する。
### クラスタの作成
```
# ansible-playbook -i inventory/development service1/site.yml
```
