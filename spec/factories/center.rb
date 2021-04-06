FactoryBot.define do
  factory :center do
    id { 1 }
    identifier { '001' }
    name { 'Center Name' }
    center_type { 'CBI' }
    administration { 'Public' }
    region { 'region' }
    department { 'department' }
    municipality { 'municipality' }
  end
end
