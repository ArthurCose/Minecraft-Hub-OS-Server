function includes(table, value)
  for _, v in ipairs(table) do
    if value == v then
      return true
    end
  end
  return false
end

return includes
