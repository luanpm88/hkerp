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
