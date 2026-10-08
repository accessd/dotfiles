-- Render the OpenAPI spec in the current buffer to a static Redoc page and open
-- it in the browser. Rebuilds on every save of that buffer, reload to see it.

local out_dir = vim.fn.stdpath 'cache' .. '/openapi-preview'

local function build(spec, out, on_success)
  vim.system({ 'npx', '-y', '@redocly/cli@2', 'build-docs', spec, '-o', out }, {}, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify(res.stderr ~= '' and res.stderr or res.stdout, vim.log.levels.ERROR, { title = 'OpenApiPreview' })
      end)
      return
    end
    if on_success then
      vim.schedule(on_success)
    end
  end)
end

vim.api.nvim_create_user_command('OpenApiPreview', function()
  local spec = vim.api.nvim_buf_get_name(0)
  if spec == '' then
    vim.notify('buffer has no file', vim.log.levels.ERROR, { title = 'OpenApiPreview' })
    return
  end

  vim.fn.mkdir(out_dir, 'p')
  local out = out_dir .. '/' .. vim.fn.sha256(spec):sub(1, 16) .. '.html'

  build(spec, out, function()
    vim.ui.open(out)
  end)

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = vim.api.nvim_create_augroup('OpenApiPreview' .. vim.api.nvim_get_current_buf(), { clear = true }),
    buffer = 0,
    callback = function()
      build(spec, out)
    end,
  })
end, { desc = 'Render the current OpenAPI spec to HTML and open it' })
