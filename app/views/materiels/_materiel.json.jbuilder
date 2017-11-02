json.extract! materiel, :id, :nom, :description, :photo, :poids, :reforme, :created_at, :updated_at
json.url materiel_url(materiel, format: :json)
