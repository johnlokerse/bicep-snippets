var varArrayOfItems = [
  'privatelink.blob.core.windows.net'
  'privatelink.blob.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.web.core.windows.net'
  'privatelink.web.core.windows.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.dfs.core.windows.net'
]

output outRemoveDupes array = union(varArrayOfItems, varArrayOfItems)
