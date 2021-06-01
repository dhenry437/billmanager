json.extract! bill, :id, :name, :amount, :date, :recurring, :user_id, :created_at, :updated_at
json.url bill_url(bill, format: :json)
