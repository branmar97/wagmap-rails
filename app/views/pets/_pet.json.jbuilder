json.extract! pet, :id, :name, :sex, :birthdate, :description, :health, :colors, :compatibilities
json.primary_breed do
  json.extract! pet.primary_breed, :id, :name
end
json.secondary_breed do
  json.extract! pet.secondary_breed, :id, :name if pet.secondary_breed
end
