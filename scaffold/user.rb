metamodel_version '0.0.1'

define :User do
  # define User model like this
  attr :nickname, :string
  attr :avatar, :string?
  attr :email, :string, :unique, default: "default@gmail.com"
end
