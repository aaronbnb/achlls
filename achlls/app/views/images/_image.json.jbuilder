json.extract! image, :id, :src, :alt, :created_at, :updated_at
json.url image_url(image, format: :json)
