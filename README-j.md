# Tsubaiso API (beta)

このドキュメントでは Tsubaiso API のベータ版の説明をします。
Tsubaiso API ベータ版では売上明細と仕入・経費明細のデータをやりとりできます。
将来のバージョンでは、ツバイソシステムの他のモジュールにアクセスするための新しいエンドポイントが加わる予定です。

## Root Endpoint

```sh
https://tsubaiso.jp
```

## リクエストのフォーマット

API へのすべてのリクエストは JSON を使って行います。

## 認証

Tsubaiso API にアクセスするためには、アクセストークンを取得する必要があります。
以下は、アクセストークンを使って売上明細一覧のデータを取得する例です。

```
$ curl -i -H "Access-Token: xxxxxxxxxxxxxxxxx" -H "Accept: application/json" -H "Content-Type: application/json" https://tsubaiso.jp/ar/list
```

## レスポンスコードとエラー処理

Code | Description
--- | --- 
`200 OK` | リクエスト成功 |
`204 No Content` | リクエストに成功したが返されるコンテンツはありません。
`401 Not Authorized` | アクセストークンが送られていないか正しくありません。
`403 Forbidden` | そのリクエストに必要な権限がありません。
`404 Not found` | 指定されたパスは正しくないか、リソースが見つかりません。
`422 Unprocessable Entity` | 1つ以上のパラメータが正しくないか不足しています。エラーメッセージで原因が判別できます。
`500 Internal Server Error` | サーバーで何らかのエラーが起こりました。
`503 Service Unavailable` | あなたの IP アドレスから非常に多くのリクエストがあった場合、このエラーが発生します。次のリクエストまで少し時間を開けてください。

## リソース

#### 売上明細

**/ar/list/:year/:month**

説明: このエンドポイントは特定の年月の売上明細の一覧を返します。年月パラメータが指定されなかった場合、現在の月の明細が返されます。

HTTP メソッド: GET

URL 構成例: 
```sh 
https://tsubaiso.jp/ar/list/2015/10 
```

JSON レスポンスの例:
```
[
    {
        "ar_reason_master_id": 0,
        "ar_receipt_attachments_count": null,
        "code": null,
        "created_at": "2015/10/05 15:26:43 +0900",
        "customer_master_id": 101,
        "dc": "d",
        "dept_code": "DEPT A",
        "id": 8833,
        "memo": "500 widgets",
        "realization_timestamp": "2015/10/31 00:00:00 +0900",
        "regist_user_code": "sample_user",
        "sales_journal_dc_id": 6832,
        "scheduled_memo": null,
        "scheduled_receive_timestamp": null,
        "update_user_code": null,
        "updated_at": "2015/10/05 15:26:43 +0900",
        "account_code": "501",
        "sales_price": 5000,
        "sales_tax": 400,
        "sales_tax_type": 18
    }, {
        "ar_reason_master_id": 121278,
        "ar_receipt_attachments_count": null,
        "code": null,
        "created_at": "2015/10/05 17:39:34 +0900",
        "customer_master_id": 895820,
        "dc": "d",
        "dept_code": "DEPT B",
        "id": 8834,
        "memo": "100 clocks",
        "realization_timestamp": "2015/10/31 00:00:00 +0900",
        "regist_user_code": "sample_user",
        "sales_journal_dc_id": 8834,
        "scheduled_memo": null,
        "scheduled_receive_timestamp": null,
        "update_user_code": null,
        "updated_at": "2015/10/05 17:39:34 +0900",
        "account_code": "500",
        "sales_price": 10000,
        "sales_tax": 800,
        "sales_tax_type": 0
    }
]
```

**/ar/show/:id**

説明: このエンドポイントは単一の売上明細を返します。

HTTP メソッド: GET

URL 構成例:
``` sh
https://tsubaiso.jp/ar/show/8833 
```

JSON レスポンスの例:
```
{
    "ar_reason_master_id": 0,
    "ar_receipt_attachments_count": null,
    "code": null,
    "created_at": "2015/10/05 15:26:43 +0900",
    "customer_master_id": 101,
    "dc": "d",
    "dept_code": "DEPT A",
    "id": 8833,
    "memo": "500 widgets",
    "realization_timestamp": "2015/10/31 00:00:00 +0900",
    "regist_user_code": "sample_user",
    "sales_journal_dc_id": 6832,
    "scheduled_memo": null,
    "scheduled_receive_timestamp": null,
    "update_user_code": null,
    "updated_at": "2015/10/05 15:26:43 +0900",
    "account_code": "501",
    "sales_price": 5000,
    "sales_tax": 400,
    "sales_tax_type": 18
}
```

**/ar/create**

説明: 売上明細を新規作成します。作成に成功した場合、新規作成された明細が JSON として返されます。

HTTP メソッド: POST

URL 構成例:
```sh
https://tsubaiso.jp/ar/create
```

Parameters:

Parameter | Necessity | Type | Description
--- | --- | --- | ---
`price` | *required* | Integer | 売上高(税込)
`realization_timestamp` | *required* | String | 明細の実現日。 "YYYY-MM-DD" 形式
`customer_master_code` | *required* | String | 取引先コード
`reason_master_code` | *required* | String | 明細の原因コード。仕訳を作成するために使われます。
`dc` | *required* | String | 原因区分。 'd' は debit の意で「増加」に、'c' は credit の意で「減少」になります。
`memo` | *required* | String | メモ。値は空文字でも構いませんが必須項目です。
`tax_code` | *required* | Integer | 税区分コード
`year` | *optional* | Integer | 年
`month` | *optional* | Integer | 月
`dept_code` | *optional* | String | 部門コード 
`sales_tax` | *optional* | Integer | 消費税額。指定されなかった場合、自動で計算されます。
`scheduled_receipt_timestamp` | *optional* | String | 入金予定日。 “YYYY-MM-DD”形式
`scheduled_memo` | *optional* | String | 入金予定に関するメモ

リクエストの例:
```sh
curl -i -H "Content-Type: application/json" -H "Accept: application/json" -H "Access-Token: XXXXXXXXXXXXXX" -X POST -d '{"year": 2015, "month": 10, "price": 5000, "realization_timestamp": "2015-10-31", "customer_master_code": "101", "dept_code": "DEPT A", "reason_master_code": "SALES", "dc": "d", "memo": "500 widgets", "tax_code": 0}' https://tsubaiso.jp/ar/create
```

**/ar/destroy/:id**

説明: 指定された id の売上明細を削除します。成功した場合 204 No Content が返ります。

HTTP メソッド: POST

URL 構成例:
```sh
https://tsubaiso.jp/ar/destroy/8833 
```

#### 仕入・経費明細

**/ap_payments/list/:year/:month**

説明: このエンドポイントは特定の年月の仕入・経費明細の一覧を返します。年月パラメータが指定されなかった場合、現在の月の明細が返されます。

HTTP メソッド: GET

URL 構成例: 
``` sh
https://tsubaiso.jp/ap_payments/list/2015/10
```

JSON レスポンスの例:
```
[
    {
        "accrual_timestamp": "2015/10/31 00:00:00 +0900",
        "ap_payment_attachments_count": null,
        "ap_reason_master_id": 1,
        "buying_journal_dc_id": 9835,
        "code": null,
        "created_at": "2015/10/06 15:45:21 +0900",
        "customer_master_id": 8201,
        "dc": "c",
        "dept_code": "DEPT C",
        "id": 6621,
        "memo": "Office Supplies for Frank",
        "need_tax_deduction": null,
        "port_type": 1,
        "preset_withholding_tax_amount": null,
        "regist_user_code": "sample_user",
        "scheduled_memo": null,
        "scheduled_pay_timestamp": null,
        "update_user_code": null,
        "updated_at": "2015/10/06 15:45:21 +0900",
        "withholding_tax_base": null,
        "withholding_tax_segment": null,
        "account_code": "604",
        "buying_price": 5000,
        "buying_tax": 400,
        "buying_tax_type": 0
    }, {
        "accrual_timestamp": "2015/10/31 00:00:00 +0900",
        "ap_payment_attachments_count": null,
        "ap_reason_master_id": 1,
        "buying_journal_dc_id": 9836,
        "code": null,
        "created_at": "2015/10/06 15:48:42 +0900",
        "customer_master_id": 101,
        "dc": "c",
        "dept_code": "SETSURITSU",
        "id": 622,
        "memo": "Television for Cafeteria",
        "need_tax_deduction": null,
        "port_type": 1,
        "preset_withholding_tax_amount": null,
        "regist_user_code": "client_user",
        "scheduled_memo": null,
        "scheduled_pay_timestamp": null,
        "update_user_code": null,
        "updated_at": "2015/10/06 15:48:42 +0900",
        "withholding_tax_base": null,
        "withholding_tax_segment": null,
        "account_code": "604",
        "buying_price": 10000,
        "buying_tax": 800,
        "buying_tax_type": 0
    }
]
```

**/ap_payments/show/:id**

説明: このエンドポイントは単一の仕入・経費明細を返します。

HTTP メソッド: GET

URL 構成例:
``` sh
https://tsubaiso.jp/ap_payments/show/6621 
```

JSON レスポンスの例:
```
{
    "accrual_timestamp": "2015/10/31 00:00:00 +0900",
    "ap_payment_attachments_count": null,
    "ap_reason_master_id": 1,
    "buying_journal_dc_id": 9835,
    "code": null,
    "created_at": "2015/10/06 15:45:21 +0900",
    "customer_master_id": 8201,
    "dc": "c",
    "dept_code": "DEPT C",
    "id": 6621,
    "memo": "Office Supplies for Frank",
    "need_tax_deduction": null,
    "port_type": 1,
    "preset_withholding_tax_amount": null,
    "regist_user_code": "sample_user",
    "scheduled_memo": null,
    "scheduled_pay_timestamp": null,
    "update_user_code": null,
    "updated_at": "2015/10/06 15:45:21 +0900",
    "withholding_tax_base": null,
    "withholding_tax_segment": null,
    "account_code": "604",
    "buying_price": 5000,
    "buying_tax": 400,
    "buying_tax_type": 0
}
```

**/ap_payments/create**

説明: 仕入・経費明細を新規作成します。作成に成功した場合、新規作成された明細が JSON として返されます。

HTTP メソッド: POST

URL 構成例:
```sh
https://tsubaiso.jp/ap_payments/create
```

Parameters:

Parameter | Necessity | Type | Description
--- | --- | --- | ---
`price` | *required* | Integer | 発生額(税込)
`accrual_timestamp` | *required* | String | 発生日。  "YYYY-MM-DD" 形式
`customer_master_code` | *required* | String | 取引先コード
`reason_master_code` | *required* | String | 明細の原因コード。仕訳を作成するために使われます。
`dc` | *required* | String | 原因区分。 'd' は「減少」に、'c' は「増加」になります。
`memo` | *required* | String | メモ。値は空文字でも構いませんが必須項目です。
`tax_code` | *required* | Integer | 税区分コード
`port_type` | *required* | Integer | エリア区分。 1 は「国内」、 2 は「国外」
`year` | *optional* | Integer | 明細の年。 年が指定された場合は月も必須項目になります。年が指定されない場合は現在の年が使われます。
`month` | *optional* | Integer | 明細の月。月が指定された場合は年も必須項目になります。月が指定されない場合は現在の月が使われます。
`dept_code` | *optional* | String | 部門コード
`buying_tax` | *optional* | Integer | 消費税額。省略された場合は自動で計算されます。
`scheduled_pay_timestamp` | *optional* | String | 支払予定日。  "YYYY-MM-DD" 形式
`scheduled_memo` | *optional* | String | 支払いに関する追加のメモ
`need_tax_deduction` | *optional* | Integer | 源泉徴収の対象とするか否か。 0:しない, 1:する
`preset_withholding_tax_amount` | *optional* | Integer | 事前設定源泉徴収額
`withholding_tax_base` | *optional* | Integer | 源泉徴収基準額。 1:消費税込額, 2:消費税抜額
`withholding_tax_segment` | *optional* | String | 源泉徴収区分コード (例: "nta2795"。 次のページを参照してください https://www.nta.go.jp/taxanswer/gensen/2795.htm)

リクエストの例:
``` sh
curl -i -H "Content-Type: application/json" -H "Accept: application/json" -H "Access-Token: XXXXXXXXXXXXXX" -X POST -d '{"year": 2015, "month": 8, "price": 5000, "accrual_timestamp": "2015-10-31", "customer_master_code": "8201", "dept_code": "DEPT C", "reason_master_code": "BUYING_IN", "dc": "c", "memo": "Office Supplies for Frank", "tax_code": 0, "port_type": 1 }' https://tsubaiso.jp/ap_payments/create
```

**/ap/destroy/:id**

説明: 指定された id の仕入・経費明細を削除します。成功した場合 204 No Content が返ります。

HTTP メソッド: POST

URL 構成例:
```sh
https://tsubaiso.jp/ap/destroy/6621 
```
