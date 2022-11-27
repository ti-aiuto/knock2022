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

item_pages = [
    "/items/10001", 
    "/items/10002", 
    "/items/10003", 
    "/items/10004", 
    "/items/10005", 
    "/items/10006", 
    "/items/10007", 
    "/items/10008", 
    "/items/10009", 
    "/items/10010", 
]

access_log = []

items_map = {}
CSV.foreach("items.csv", headers: true) do |row|
    items_map[row['id'].to_i] = row['price'].to_i
end


orders = []
CSV.foreach("orders.csv", headers: true) do |row|
    orders << row
end

order_statements = []
CSV.foreach("order_statements.csv", headers: true) do |row|
    order_statements << row
end

def generate_access_log_item(accessed_at, path, ua, user_id, method: 'GET', status_code: '200')
   
    [accessed_at.utc.iso8601, 
        accessed_at.to_date.iso8601, 
        path, 
        method, 
        status_code, 
        ua, 
        SecureRandom.uuid, 
        user_id
    ]
end
Time.zone =TZInfo::Timezone.get('Asia/Tokyo')  

base_datetime = Time.zone.local(2022, 11, 10)
CSV.foreach("users.csv", headers: true) do |row|
    user_id =  row['id'].to_i

    ua = uas.sample
    # ランダムに回遊したことにする
    rand(5).times do 
        accessed_at = base_datetime + rand(3600 * 24 * 20)
        access_log << generate_access_log_item(accessed_at, static_pages.sample, ua, row['id'].to_i)
    end
    rand(10).times do 
        accessed_at = base_datetime + rand(3600 * 24 * 20)
        access_log << generate_access_log_item(accessed_at, item_pages.sample, ua, row['id'].to_i)
    end

    # 仮登録完了のログ
    registered_at = Time.zone.parse(row['registered_at'])
    signup_time = registered_at - rand(300)

    access_log << generate_access_log_item(signup_time, '/signup', ua, user_id)
    if rand() <= 0.1
        # たまに失敗
        access_log << generate_access_log_item(registered_at - 3.seconds, '/signup', ua, user_id, method: 'POST', status_code: 400)    
    end
    access_log << generate_access_log_item(registered_at, '/signup', ua, user_id, method: 'POST', status_code: 302)

    # 本登録完了のログ
    if row['confirmed_at'].present?
        confirmed_at = Time.zone.parse(row['confirmed_at'])
        access_log << generate_access_log_item(confirmed_at - rand(20), '/signup/activate', ua, user_id)
        if rand() <= 0.1
        # たまに失敗
        access_log << generate_access_log_item(confirmed_at - 3.seconds, '/signup/activate', ua, user_id, method: 'POST', status_code: 400)    
        end
        access_log << generate_access_log_item(confirmed_at, '/signup/activate', ua, user_id, method: 'POST', status_code: 302)    
    end

    # カートへの追加・注文
    orders.select { |order| order['user_id'].to_i == user_id }.each do |order|
        ordered_at = Time.zone.parse(order['ordered_at'])

        added_card = ordered_at - 1.minute - rand(60)
        access_log << generate_access_log_item(ordered_at, '/cart', ua, user_id)    

        if rand() <= 0.1
        # たまに失敗
            access_log << generate_access_log_item(added_card + rand(20), '/checkout', ua, user_id, method: 'POST', status_code: 400)    
        end
        access_log << generate_access_log_item(ordered_at, '/checkout', ua, user_id, method: 'POST', status_code: 302)    
    end
end

1000.times do 
    ua = uas.sample
    accessed_at = base_datetime + rand(3600 * 24 * 20)
    access_log << generate_access_log_item(accessed_at, static_pages.sample, ua, nil)
end


CSV.open('access_log.csv','w') do |csv|
    csv << ['time', 'date_jst', 'path', 'method', 'status_code', 'user_agent', 'request_id', 'user_id']
    access_log.each do |log_item|
        csv << log_item
    end
end

