module UrlBuilder
  def url(root, resource, method, year = nil, month = nil)
    require_yms = %w(ar ap_payments manual_journals reimbursements reimbursement_transactions bank_accounts)
    if require_yms.include?(resource) && method == "list"
      return root + "/" + resource + "/list/" + year.to_s + "/" + month.to_s + "/"
    else
      return root + "/" + resource + "/" + method + "/"
    end
  end
end