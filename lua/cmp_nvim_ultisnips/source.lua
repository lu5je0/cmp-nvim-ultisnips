local cmp = require('cmp')
local cmp_snippets = require('cmp_nvim_ultisnips.snippets')

local source = {}
function source.new(config)
  local self = setmetatable({}, { __index = source })
  self.config = config
  return self
end

function source:get_keyword_pattern()
  return '\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)'
end

function source:get_debug_name()
  return 'ultisnips'
end

function source:complete(_, callback)
  local items = {}
  local info = cmp_snippets.load_snippet_info()
  for _, snippet_info in pairs(info) do
    -- skip regex and expression snippets for now
    if not snippet_info.options or not snippet_info.options:match('[re]') then
      local item = {
        word =  snippet_info.tab_trigger,
        label = snippet_info.tab_trigger,
        kind = cmp.lsp.CompletionItemKind.Snippet,
        userdata = snippet_info,
      }
      table.insert(items, item)
    end
  end
  callback(items)
end

function source.resolve(self, completion_item, callback)
  local doc_string = self.config.documentation(completion_item.userdata)
  if doc_string ~= nil then
    completion_item.documentation = {
      kind = cmp.lsp.MarkupKind.Markdown,
      value = doc_string
    }
  end
  callback(completion_item)
end

function source:execute(completion_item, callback)
  vim.call('UltiSnips#ExpandSnippet')
  callback(completion_item)
end

function source:is_available()
  -- if UltiSnips is installed then this variable should be defined
  return vim.g.UltiSnipsExpandTrigger ~= nil
end

function source:clear_snippet_caches()
  cmp_snippets.clear_caches()
end

return source