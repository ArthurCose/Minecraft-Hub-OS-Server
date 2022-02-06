local function append_table(list, other_list)
  for _, value in ipairs(other_list) do
    list[#list+1] = value
  end
end

return append_table
