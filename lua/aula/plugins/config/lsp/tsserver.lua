local function org_imports()
  vim.lsp.buf.execute_command({
    command = '_typescript.organizeImports',
    arguments = { vim.api.nvim_buf_get_name(0) }
  })
end

return {
  commands = {
    TsOrganizeImports = {
      org_imports,
      description = 'Organize Imports'
    }
  }
}
