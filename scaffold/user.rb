metamodel_version '0.0.1'

define :User do |j|
  # define User model like this
  j.nickname :string
  j.avatar :string
  j.email :string, :unique, default: "default@gmail.com"
end
