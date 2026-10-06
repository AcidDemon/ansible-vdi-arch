-- linemode: size + mtime
function Linemode:size_and_mtime()
  local t = math.floor(self._file.cha.mtime or 0)
  local ts
  if t == 0 then
    ts = ""
  elseif os.date("%Y", t) == os.date("%Y") then
    ts = os.date("%b %d %H:%M", t)      -- same year: "Sep 27 14:22"
  else
    ts = os.date("%b %d  %Y", t)        -- different year: "Sep 27  2024"
  end

  local size = self._file:size()
  local sz   = size and ya.readable_size(size) or "-"
  return string.format("%s %s", sz, ts)
end
