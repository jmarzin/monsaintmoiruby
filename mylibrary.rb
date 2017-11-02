module MyLibrary
  extend FFI::Library
  ffi_lib Rails.root.joint('distance.so')
  # double lat1, double lon1, double lat2, double lon2
  # return distance in meters
  attach_function :getDistance, [:double, :double, :double, :double], :double
end