require 'active_support/all'
require 'csv'

users = []


base_datetime = Time.new(2022, 11, 10)
300.times do |index|
    registered_at = base_datetime + rand(20).days + rand(24).hours + rand(3600)
    confirmed_at = nil
    if rand() <= 0.8
        if rand() <= 0.8
            confirmed_at = registered_at + 30 + rand(3600 * 3)
        else
            confirmed_at = registered_at + 30 + rand(8).days + rand(3600 * 3)
        end
    end
    users << [200001 + index, registered_at.utc.iso8601, confirmed_at&.utc&.iso8601]
end

CSV.open('users.csv','w') do |csv|
    csv << ['id', 'registered_at', 'confirmed_at']
    users.each do |user|
        csv << user
    end
end
