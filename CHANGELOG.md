# Tsubaiso SDK (Ruby) 変更点

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
