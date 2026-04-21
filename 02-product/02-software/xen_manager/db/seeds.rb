User.find_or_create_by!(username: "root") do |u|
  u.password = "root"
  u.role     = "admin"
end
