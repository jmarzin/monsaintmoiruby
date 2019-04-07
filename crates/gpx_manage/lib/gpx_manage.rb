require "helix_runtime"

begin
  require "gpx_manage/native"
rescue LoadError
  warn "Unable to load gpx_manage/native. Please run `rake build`"
end
