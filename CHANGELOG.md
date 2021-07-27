# Tsubaiso SDK (Ruby) 変更点
## 1.2.7

### create_bank_account_master(options)
引数 options のハッシュキー を変更しました。
変更前後ともに、設定するものは為替レートマスタIDです。

    変更前：currency_rate_master_code
    変更後：currency_rate_master_id

### update_staff_data(options)
引数を変更しました。

    変更後：update_staff_data(staff_data_id, options)

引数 options に、項目`code` を追加しました。
