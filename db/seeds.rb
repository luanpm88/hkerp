# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ContactType.create(name: "Customer")
ContactType.create(name: "Supplier")
ContactType.create(name: "Agent")

User.create(:email => "admin@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Super",:last_name => "Admin")
User.create(:email => "nguyendtd@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Nguyen",:last_name => "Do Thi Da")
User.create(:email => "tuanthm@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Tuan",:last_name => "Thai Hoang Minh")
User.create(:email => "vietdq@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Viet",:last_name => "Do Quoc")
User.create(:email => "trungpn@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Trung",:last_name => "Pham Nguyen")
User.create(:email => "thuydp@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Thuy",:last_name => "Do Thi Phuong")
User.create(:email => "luanpm@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Luan",:last_name => "Pham")
User.create(:email => "tiennv@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Tien",:last_name => "Nguyen Van")
User.create(:email => "trinhptt@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Trinh",:last_name => "Phan Thi Tuyet")
User.create(:email => "bangdh@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Bang",:last_name => "Do Hai")
User.create(:email => "phuongnt@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Phuong",:last_name => "Nguyen Tien")
User.create(:email => "quannt@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Quan",:last_name => "Nguyen The")

PaymentMethod.create(name: "Tiền mặt")
PaymentMethod.create(name: "Chuyển khoản")

Tax.create(name: "VAT 0%", rate: 0)
Tax.create(name: "VAT 10%", rate: 10)

@HK = Contact.create(name: "Công Ty TNHH Giải Pháp CNTT & Truyền Thông Hoàng Khang",
                address: "178 Nguyễn Văn Lượng, Phường 17, Quận Gò Vấp, TP HCM",
                phone: "(08) 3984 7690",
                fax: "(08) 3984 7691",
                hotline: "(08) 2212 9454",
                tax_code: "0306146736",
                website: "www.hoangkhang.com.vn",
                email: "info@hoangkhang.com.vn",
                contact_type_id: ContactType.supplier,
                is_mine: true
              )

Contact.where(name: "Công Ty TNHH Giải Pháp CNTT & Truyền Thông Hoàng Khang").first.children.create(name: "Chi Nhánh: Công Ty TNHH Giải Pháp CNTT & Truyền Thông Hoàng Khang",
                address: "140/17/38 Lê Đức Thọ, Phường 6, Quận Gò Vấp, TP HCM",
                phone: "(08) 3984 7690",
                fax: "(08) 3984 7691",
                hotline: "(08) 2212 9454",
                tax_code: "0306146736",
                website: "www.hoangkhang.com.vn",
                email: "info@hoangkhang.com.vn",
                contact_type_id: ContactType.supplier)

Role.create(name: "admin")
Role.create(name: "user")
Role.create(name: "attendance_manager")
Role.create(name: "salesperson")
Role.create(name: "accountant")
Role.create(name: "storage_manager")
Role.create(name: "purchase_manager")

user = User.where(:email => "luanpm@hoangkhang.com.vn").first
user.ATT_No = 123
user.save
user.add_role Role.where(name: "admin").first

user = User.where(:email => "luanpm@hoangkhang.com.vn").first
user.ATT_No = 123
user.save
user.add_role Role.where(name: "attendance_manager").first

user = User.where(:email => "nguyendtd@hoangkhang.com.vn").first
user.ATT_No = 22
user.save
user.add_role Role.where(name: "attendance_manager").first

user = User.where(:email => "tuanthm@hoangkhang.com.vn").first
user.ATT_No = 124
user.save

user = User.where(:email => "vietdq@hoangkhang.com.vn").first
user.ATT_No = 21
user.save

user = User.where(:email => "thuydp@hoangkhang.com.vn").first
user.ATT_No = 40
user.save

user = User.where(:email => "tiennv@hoangkhang.com.vn").first
user.ATT_No = 52
user.save

user = User.where(:email => "trinhptt@hoangkhang.com.vn").first
user.ATT_No = 128
user.save

user = User.where(:email => "bangdh@hoangkhang.com.vn").first
user.ATT_No = 70
user.save

user = User.where(:email => "phuongnt@hoangkhang.com.vn").first
user.ATT_No = 127
user.save

user = User.where(:email => "quannt@hoangkhang.com.vn").first
user.ATT_No = 25
user.save

user = User.where(:email => "trungpn@hoangkhang.com.vn").first
user.destroy

User.all.each do |user|
        user.add_role Role.where(name: "user").first
end

OrderStatus.create(name: "draft", description: "Draft")
OrderStatus.create(name: "new", description: "New")
OrderStatus.create(name: "items_confirmed", description: "Items Confirmed")
OrderStatus.create(name: "price_confirmed", description: "Price Confirmed")
OrderStatus.create(name: "quotation", description: "Quotation")
OrderStatus.create(name: "confirmed", description: "Order Confirmed")
OrderStatus.create(name: "outdated", description: "Outdated")