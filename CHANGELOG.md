# Tsubaiso SDK (Ruby) 変更点

## 1.2.16
### index_bank_balances(options)
index_bank_balances(options)を追加しました。

## 1.2.1５
### create_petty_cash_reason_master(options)
引数 options の、項目 reason_taxes_onestr をreason_taxes_onestrに変更しました。

### update_petty_cash_reason_master(petty_cash_reason_master_id, options)
引数 options の、項目 reason_taxes_onestr をreason_taxes_onestrに変更しました。

### update_ar_reason_masters(id, options)
引数 options のうち、未設定の項目はAPIに渡さないよう変更しました。

### update_ap_reason_masters(id, options)
引数 options のうち、未設定の項目はAPIに渡さないよう変更しました。

### update_reimbursement_reason_masters(id, options)
引数 options のうち、未設定の項目はAPIに渡さないよう変更しました。

## 1.2.14
### create_bank_reason_masters(options)
引数 options に、項目 `bank_reason_taxes` を追加しました。

### create_petty_cash_reason_master(options)
引数 options に、項目 `reason_taxes_onestr`を追加しました。

### update_bank_reason_masters(options)
引数 options に、項目 `bank_reason_taxes`を追加しました。

### update_petty_cash_reason_master(petty_cash_reason_master_id, options)
引数 options に、項目 `reason_taxes_onestr`を追加しました。

### create_ar_segment_masters(options)
引数 options に、項目 `no`を追加しました。

### create_ap_segment_masters(options)
引数 options に、項目 `no`を追加しました。


## 1.2.13
### create_purchase(options)
引数 options に、項目 `scheduled_pay_method`、`scheduled_pay_interface_id` を追加しました。

### find_or_create_purchase(options)
引数 options に、項目 `scheduled_pay_method`、`scheduled_pay_interface_id` を追加しました。

### update_purchase(options)
引数 options に、項目 `scheduled_pay_method`、`scheduled_pay_interface_id` を追加しました。

### list_ap_cashflow_schedule(year, month)
引数 options を追加しました。

    変更後：list_ap_cashflow_schedule(year, month, options = {})

options で渡すことのできる項目は `pay_method` です。


## 1.2.8

### update_staff_data(options)
引数を変更しました。

    変更後：update_staff_data(staff_data_id, options)

引数 options に、項目`code` を追加しました。
