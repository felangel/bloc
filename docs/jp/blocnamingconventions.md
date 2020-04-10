# 命名規則

!> 下記の命名規則はあくまで任意であり、守らなくてはならないものではありません。自分で使いたい命名規則があればそれを使ってもらって問題ありません。Bloc ライブラリー内の例アプリでも簡素化のためにこの命名規則に沿っていない場合もあります。複数の開発者が携わる大きなプロジェクトの場合はこの命名規則に沿うことを強く推奨します。

## Event の命名規則

> Event すでに起きたことであるからは**過去形**であるべき。

### 構造

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

￥?> 初期ロード用の event はこの構造であるべき: `ブロックの種名` + `Started`

#### 例

✅ **正解**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **間違い**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## State の命名規則

> State はアプリのある状態を切り取ったものであるため、名詞であるべき。

### 構造

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> `State` should be one of the following: `Initial` | `Success` | `Failure` | `InProgress` and
initial states should follow the convention: `BlocSubject` + `Initial`.
?> `State` はこれらのどれかであるべき: `Initial` | `Success` | `Failure` | `InProgress` かつ初期 state はこの規則に沿うべき: `ブロックの種名` + `Initial`.

#### 例

✅ **正解**

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **間違い**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
