metamodel_version '0.0.1'

define :User do |j|
  # define User model like this
  j.string 'nickname', 'NICKNAME'
  j.string 'avatar'
  j.string 'user_id'
end
