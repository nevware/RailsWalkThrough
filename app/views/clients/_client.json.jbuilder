json.extract! client, :id, :name, :status, :created_at, :updated_at
json.url client_url(client, format: :json)
