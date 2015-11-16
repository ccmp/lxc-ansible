# Inventory file
* development: 開発環境用inventoryファイル
* production: 本番環境用inventoryファイル
 * productionのInventoryファイルは利用できない(未完成)
 * 将来的にはInventoryファイルの切り替えでデプロイ先の環境を切り替えられるようにする。
  * あるいは同様のDynamic Inventoryを利用する。

# InventoryのGroup名について
* グループ名を物理ホストの別名としてはじめに定義し、それを利用して各ホストグループをchildrenとして定義している。
 * この方法がAnsible的に正しいかは不明。
 * 従って最初の定義ではグループ名であるが所属するホストは原則1つになる。

## 最初の定義
'''
                           +-------+
                           |MANAGER|
                           +-+-----+
                             |
  +------+------+------+-----+
  |      |      |      |
+----+ +----+ +----+ +----+
|LVS1| |LVS2| |WEB1| |WEB2|
+----+ +----+ +----+ +----+
'''
* LXCホスト4台＋managerホスト1台でのクラスタ構成
 * LVS1,LVS2,WEB1,WEB2,MANAGER クラスタを構成する物理ホストの別名
 * lvs01,lvs02,web01,web02,mng01 実際にクラスタを構成する実際の物理ホスト名

* 最初の定義で別名と実際のホスト名の紐付けを定義する。
```
[LVS1]
lvs01
[LVS2]
lvs02
[WEB1]
web01
[WEB2]
web02
[MANAGER]
mng01
```
 * 以降、クラスタを構成する要素としての物理ホストを変更する場合はこの箇所を変更する。
 
## その他の定義
 * 最初に定義したホストの別名を利用して以降のグループを定義していく。
### 物理ホストの役割のグループ
 * それぞれの物理ホストおいて必要なセットアップごとのグループ
  * 各ホストは自身に必要なセットアップのグルーブに所属している必要がある。
  
 * mnghost : managerのセットアップが必要なホスト
 * lvshost : LVSコンテナホストとしてのセットアップが必要なホスト
 * webhost : WEBコンテナホストとしてのセットアップが必要なホスト
 * lxchost : LXCホストとしてセットアップが必要なホスト
  * LXCのセットアップが必要な物理ホストはこのグループに所属している必要がある。
  * lvshostなどのグループではLXCのセットアップは行われない。
  
 * これらのグループはphysical以下の物理ホストのセットアップにおいてhostsに指定されるグループとして利用される。
```
[lvshost:children]
LVS1
LVS2

[webhost:children]
WEB1
WEB2

[lxchost:children]
mnghost
lvshost
webhost
```
#### 変数の定義
 * それぞれのセットアップに必要な変数はgroup_vars以下の<グループ名>.yml定義される
 * group_vars/mnghost.yml
 * group_vars/lvshost.yml
 * group_vars/webhost.yml
 * group_vars/lxchost.yml
 
### managerサーバとして利用するホストの定義
* コンテナのイメージなどを作成する際に利用するmanagerの定義
```
[manager:children]
MANAGER
```

### サーブスごとのグループ
 * サービスごとに利用するホストのグループの定義
 * 各サービスでplaybookを適用する
 * service1とservice2でinventoryファイルの利用/参照の仕方が異なっているので注意
  * service2の方がリファインされた方法(だと思われる)

### service1

### service2



 