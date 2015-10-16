# Tsubaiso API (beta)

This is the documentation for the beta version of the Tsubaiso API. The beta version currently handles accounts receivables and accounts payable transactions. Future versions of this API will add new endpoints to access other modules of the Tsubaiso system.

## Root Endpoint

```sh
https://tsubaiso.net
```


## Request Format

We ask that all requests to the API be made using JSON.

## Authentication

The user must provide their access token in order to access the Tsubaiso API.

```
$ curl -i -H "Access-Token: xxxxxxxxxxxxxxxxx" -H "Accept: application/json" -H "Content-Type: application/json" https://tsubaiso.net/ar/list
```

## Response Codes and Error Handling

Code | Description
--- | --- 
`200 OK` | A successful request was made. |
`204 No Content` | A successful request was made but no content is passed back.
`401 Not Authorized` | The access token was not provided or was incorrect.
`403 Forbidden` | You do not have the correct privileges to make this request.
`404 Not found` | Path is incorrect or resource was not found at the specified path.
`422 Unprocessable Entity` | One or more parameters were incorrect or insufficient. The error message will tell you the reason.
`500 Internal Server Error` | There was an error on the server.
`503 Service Unavailable` | This error occurs when there are too many requests coming from your IP address. Wait a little bit to make your next request.

## Resources

#### Accounts Receivables

**/ar/list/:year/:month**

Description: This endpoint returns a list of accounts receivables transactions for a particular month. If no year and month parameters are provided. It returns the transactions for the current month.

Method: GET

URL Structure: 
```sh 
https://tsubaiso.net/ar/list/2015/10 
```

Sample JSON response:
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

Description: This endpoint returns a single accounts receivable transaction.

Method: GET

URL Structure:
``` sh
https://tsubaiso.net/ar/show/8833 
```

Sample JSON response:
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

Description: Creates a new accounts receivable transaction. The created transaction will be sent back as JSON if successful.

Method: POST

URL Structure:
```sh
https://tsubaiso.net/ar/create
```

Parameters:

Parameter | Necessity | Type | Description
--- | --- | --- | ---
`price` | *required* | Integer | Amount of the transaction.
`realization_timestamp` | *required* | String | Actual date of the transaction. Format must be "YYYY-MM-DD"
`customer_master_code` | *required* | String | Code of the transaction party.
`reason_master_code` | *required* | String | Reason of the transaction. This is used to create the journal entry.
`dc` | *required* | String | 'd' if the transaction was a debit to AR, 'c' if it was a credit.
`memo` | *required* | String | Memo for the transaction. Can be blank but must be provided.
`tax_code` | *required* | Integer | Tax code for the transaction.
`year` | *optional* | Integer | Year of the transaction.
`month` | *optional* | Integer | Month of the transaction.
`dept_code` | *optional* | String | Code of the internal department involved.
`sales_tax` | *optional* | Integer | Sales tax on the transaction. Is automatically calculated if not provided.
`scheduled_receipt_timestamp` | *optional* | String | Date of receipt. Format must be “YYYY-MM-DD”.
`scheduled_memo` | *optional* | String | Optional memo regarding receipt of funds.

Sample Request:
```sh
curl -i -H "Content-Type: application/json" -H "Accept: application/json" -H "Access-Token: XXXXXXXXXXXXXX" -X POST -d '{"year": 2015, "month": 10, "price": 5000, "realization_timestamp": "2015-10-31", "customer_master_code": "101", "dept_code": "DEPT A", "reason_master_code": "SALES", "dc": "d", "memo": "500 widgets", "tax_code": 0}' https://tsubaiso.net/ar/create
```

**/ar/destroy/:id**

Description: Destroys the accounts receivable transaction specified as the id. Returns a status of 204 No Content.

Method: POST

URL Structure:
```sh
https://tsubaiso.net/ar/destroy/8833 
```

#### Accounts Payables

**/ap_payments/list/:year/:month**

Description: Returns a list of accounts payables transactions for a particular month. If no year and month parameters are provided. It returns the transactions for the current month.

Method: GET

URL Structure: 
``` sh
https://tsubaiso.net/ap_payments/list/2015/10
```

Sample JSON response:
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

Description: This endpoint returns a single accounts payable transaction.

Method: GET

URL Structure:
``` sh
https://tsubaiso.net/ap_payments/show/6621 
```

Sample JSON response:
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

Description: Creates a new accounts payable transaction. The created transaction will be sent back as JSON if successful.

Method: POST

URL Structure:
```sh
https://tsubaiso.net/ap_payments/create
```

Parameters:

Parameter | Necessity | Type | Description
--- | --- | --- | ---
`price` | *required* | Integer | Amount of the transaction.
`accrual_timestamp` | *required* | String | Actual date of the transaction. Format must be "YYYY-MM-DD"
`customer_master_code` | *required* | String | Code of the transaction party.
`reason_master_code` | *required* | String | Reason of the transaction. This is used to create the journal entry.
`dc` | *required* | String | 'd' if the transaction was a debit to AP, 'c' if it was a credit.
`memo` | *required* | String | Memo for the transaction. Can be blank but must be provided.
`tax_code` | *required* | Integer | Tax code for the transaction.
`port_type` | *required* | Integer | 1 for domestic transaction. 2 for foreign transaction.
`year` | *optional* | Integer | Year of the transaction. If provided, month must be provided as well. Will use current year if not provided.
`month` | *optional* | Integer | Month of the transaction. If provided, year must be provided as well. Will use current month if not provided.
`dept_code` | *optional* | String | Code of the internal department involved.
`buying_tax` | *optional* | Integer | Sales tax on the transaction. Is automatically calculated if not provided.
`scheduled_pay_timestamp` | *optional* | String | Date of payment. Format must be "YYYY-MM-DD".
`scheduled_memo` | *optional* | String | Optional memo regarding payment of funds.
`need_tax_deduction` | *optional* | Integer | 1 if tax needs to be withheld. 0 if not necessary.
`preset_withholding_tax_amount` | *optional* | Integer | Withholding tax amount
`withholding_tax_base` | *optional* | Integer | 1 if withholding tax includes sales tax, 2 if it does not.
`withholding_tax_segment` | *optional* | String | National Tax Agency tax code (ex: "nta2795" references https://www.nta.go.jp/taxanswer/gensen/2795.htm)

Sample Request:
``` sh
curl -i -H "Content-Type: application/json" -H "Accept: application/json" -H "Access-Token: XXXXXXXXXXXXXX" -X POST -d '{"year": 2015, "month": 8, "price": 5000, "accrual_timestamp": "2015-10-31", "customer_master_code": "8201", "dept_code": "DEPT C", "reason_master_code": "BUYING_IN", "dc": "c", "memo": "Office Supplies for Frank", "tax_code": 0, "port_type": 1 }' https://tsubaiso.net/ap_payments/create
```

**/ap/destroy/:id**

Description: Destroys the accounts payable transaction specified as the id. Returns a status of 204 No Content.

Method: POST

URL Structure:
```sh
https://tsubaiso.net/ap/destroy/6621 
```
