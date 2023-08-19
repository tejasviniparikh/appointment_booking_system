class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :full_name, :email, :mobile_no
end
