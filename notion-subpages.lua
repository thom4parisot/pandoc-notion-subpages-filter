-- Module pandoc.path is required and was added in version 2.12
PANDOC_VERSION:must_be_at_least '2.12'

local List = require 'pandoc.List'
local path = require 'pandoc.path'
local system = require 'pandoc.system'

local function decodeURI(s)
    -- first replace '+' with ' '
    --   then, on the resulting string, decode % encoding
    local str = s:gsub("+", " ")
        :gsub('%%(%x%x)', function (code)
          return string.char(tonumber(code, 16))
        end)
    return str
    -- assignment to str removes the second return value of gsub
end

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

local function lines_from(file)
  if not file_exists(file) then return {} end
  local f = io.open(file, "rb")
  local content = f:read("*all")
  f:close()
  return content
end

local function inline_md (filepath)
  -- local fh = io.open(filepath)
  -- local contents = pandoc.read(fh:read '*a', 'markdown').blocks
  local contents = lines_from(filepath)

  -- contents = system.with_working_directory(
  --   path.directory(filepath),
  --   function ()

  --   end
  -- ).content
  -- fh:close()

  print('@@' .. contents)

  return pandoc.RawInline(contents, 'markdown')
end

function transclude (el)
  if el.t == 'Link' then
    local filepath = decodeURI(el.target)

    if file_exists(filepath) then
      return inline_md(filepath)
    else
      -- print (filepath, file_exists(filepath))
    end
  else
    return el
  end
end

function transclude_document (doc)
  local hblocks = {}
  local includes = {}

  for k,block in pairs(doc.blocks) do
    local links_count = 0
    local md_links_count = 0

    pandoc.walk_block(block, {
      Link = function (el)
        links_count = links_count + 1

        if el.target:match('.md$') then
          md_links_count = md_links_count + 1
          includes[k] = decodeURI(el.target)
        end

        return el
      end,
    })

    -- in that case, the paragraph contains a link inclusion
    if (links_count == 1 and md_links_count == 1) then
      local fh = io.open(includes[k])
      local contents = pandoc.read(fh:read '*a', 'markdown').blocks
      doc.blocks[k] = pandoc.Div(contents)
      fh:close()
    end
  end

  return pandoc.Pandoc(doc.blocks, doc.meta)
end

return {{ Pandoc = transclude_document }}
