json.extract! timesheet, :id, :amount, :unit, :assignment_id, :status, :start_date, :end_date, :created_at, :updated_at
json.url timesheet_url(timesheet, format: :json)
