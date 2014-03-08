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

User.create(:email => "admin@hoangkhang.com.vn", :password => "aA456321@", :password_confirmation => "aA456321@")

PaymentMethod.create(name: "Tiền mặt")
PaymentMethod.create(name: "Chuyển khoản")

Tax.create(name: "NONE", rate: 0)
Tax.create(name: "VAT 10%", rate: 10)

@HK = Contact.create(name: "Công Ty TNHH Giải Pháp CNTT & Truyền Thông Hoàng Khang",
                address: "178 Nguyễn Văn Lượng, Phường 17, Quận Gò Vấp, TP HCM",
                phone: "(08) 3984 7690",
                fax: "(08) 3984 7691",
                hotline: "(08) 2212 9454",
                tax_code: "0306146736",
                website: "www.hoangkhang.com.vn",
                email: "info@hoangkhang.com.vn",
                contact_type_id: ContactType.supplier
              )

@HK.children.create(name: "Chi Nhánh: Công Ty TNHH Giải Pháp CNTT & Truyền Thông Hoàng Khang",
                address: "140/17/38 Lê Đức Thọ, Phường 6, Quận Gò Vấp, TP HCM",
                phone: "(08) 3984 7690",
                fax: "(08) 3984 7691",
                hotline: "(08) 2212 9454",
                tax_code: "0306146736",
                website: "www.hoangkhang.com.vn",
                email: "info@hoangkhang.com.vn",
                contact_type_id: ContactType.supplier)