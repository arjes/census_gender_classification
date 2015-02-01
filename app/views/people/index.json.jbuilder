json.array!(@people) do |person|
  json.extract! person, :id, :gender, :height, :weight
  json.url person_url(person, format: :json)
end
