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

Contact.where(name: "Chi Nhánh: Công Ty TNHH Giải Pháp CNTT & Truyền Thông Hoàng Khang").first.children.create(name: "Chi Nhánh: Công Ty TNHH Giải Pháp CNTT & Truyền Thông Hoàng Khang",
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

user = User.where(:email => "luanpm@hoangkhang.com.vn").first
user.ATT_No = 123
user.save