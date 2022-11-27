require 'active_support/all'
require 'csv'

orders = []
order_statements = []

current_order_count = 5001

items_map = {}
CSV.foreach("items.csv", headers: true) do |row|
    items_map[row['id'].to_i] = row['price'].to_i
end


CSV.foreach("users.csv", headers: true) do |row|
    if row['confirmed_at'].blank?
        next
    end
    confirmed_at = Time.parse(row['confirmed_at'])

    base_datetime =confirmed_at + 600 + rand(3600)
    rand(10).times do
        total = 0
        order_items = items_map.keys.sample((1 + rand(8)))
        order_items.each do |order_item_id|
            item_quantity = 1 + rand(10)
            order_statements << [current_order_count, order_item_id, item_quantity]
            total += item_quantity * items_map[order_item_id]
        end

        orders << [current_order_count,row['id'].to_i, base_datetime.utc.iso8601, total]
        base_datetime += 3600 + rand(3600 * 24 * 2)
        current_order_count += 1
    end
end

CSV.open('orders.csv','w') do |csv|
    csv << ['id',  'user_id', 'ordered_at', 'total']
    orders.each do |order|
        csv << order
    end
end

CSV.open('order_statements.csv','w') do |csv|
    csv << ['order_id',  'item_id', 'quantity']
    order_statements.each do |order_statement|
        csv << order_statement
    end
end
