metamodel_version '0.0.1'

define :User do
  # define User model like this
  var nickname, :string
  let avatar, :string
  var email, :string, :unique, default: "default@gmail.com"
end
