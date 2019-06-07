# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

(1..15).each do |n|
  Server.create({
    :server_name => "server#{n}.onehouronelife.com",
    :created_at => Date.new(2019, 3, 9),
  })
end
Server.create({
  :server_name => "bigserver1.onehouronelife.com",
  :created_at => Time.at(1548458068),
  :removed_at => Time.at(1548809524),
})
Server.create({
  :server_name => "bigserver2.onehouronelife.com",
  :created_at => Time.at(1548804597),
})

