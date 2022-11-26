require 'active_support/all'
require 'csv'
require 'securerandom'

uas = [
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Mobile/15E148 Safari/604.1", 
    "Mozilla/5.0 (Linux; Android 11; Pixel 4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36", 
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:107.0) Gecko/20100101 Firefox/107.0"
]

static_pages = [
    "/", 
    "/items", 
    "/ranking", 
    "/ranking/daily",     
]

access_log = []

items_map = {}
CSV.foreach("items.csv", headers: true) do |row|
    items_map[row['id'].to_i] = row['price'].to_i
end


order_id_to_order = []
CSV.foreach("orders.csv", headers: true) do |row|
    order_id_to_order[row['id'].to_i] = {row: row}
end

user_id_to_order_statements = []
CSV.foreach("order_statements.csv", headers: true) do |row|
    
end

def generate_access_log_item(accessed_at, url, ua, user_id)
   
    [accessed_at.utc.iso8601, 
        accessed_at.to_date.iso8601, 
        url, 
        "GET", 
        200, 
        ua, 
        SecureRandom.uuid, 
        user_id
    ]
end
Time.zone =TZInfo::Timezone.get('Asia/Tokyo')  

base_datetime = Time.zone.local(2022, 11, 10)
CSV.foreach("users.csv", headers: true) do |row|
    ua = uas.sample
    # ランダムに回遊したことにする
    if rand() <= 0.5
        accessed_at = base_datetime + rand(3600 * 24 * 20)
        access_log << generate_access_log_item(accessed_at, static_pages.sample, ua, row['id'].to_i)
    end
    if rand() <= 0.5
        accessed_at = base_datetime + rand(3600 * 24 * 20)
        access_log << generate_access_log_item(accessed_at, static_pages.sample, ua, row['id'].to_i)
    end
    if rand() <= 0.5
        accessed_at = base_datetime + rand(3600 * 24 * 20)
        access_log << generate_access_log_item(accessed_at, static_pages.sample, ua, row['id'].to_i)
    end
    if rand() <= 0.5
        accessed_at = base_datetime + rand(3600 * 24 * 20)
        access_log << generate_access_log_item(accessed_at, static_pages.sample, ua, row['id'].to_i)
    end

end

1000.times do 
    ua = uas.sample
    accessed_at = base_datetime + rand(3600 * 24 * 20)
    access_log << generate_access_log_item(accessed_at, static_pages.sample, ua, nil)
end


p access_log