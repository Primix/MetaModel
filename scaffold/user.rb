metamodel_version '0.0.1'

define :User do |j|
  # define User model like this
  j.nickname :string, :specify => [:transform, :unique]
  j.avatar :string
  j.string :string
end
