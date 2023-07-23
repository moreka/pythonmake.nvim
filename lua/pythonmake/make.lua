local M = {}

function M.make()
  local lines = { "" }
  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local bufname = vim.fn.expand "%:~:."

  local makeprg = vim.api.nvim_buf_get_option(bufnr, "makeprg")
  if not makeprg then
    return
  end

  local cmd = vim.fn.expandcmd(makeprg)

  -- create/recall the output buffer
  local output_bufnr = vim.g["mo_runner_outputbufid"]
  if not output_bufnr then
    local prev_win = vim.api.nvim_get_current_win()
    vim.api.nvim_command "80vsplit" -- TODO: make configurable
    local win = vim.api.nvim_get_current_win()
    output_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, output_bufnr)
    vim.g["mo_runner_outputbufid"] = output_bufnr
    vim.api.nvim_set_current_win(prev_win)
  end
  vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, { bufname .. " output:" })

  local function on_exit()
    vim.fn.setqflist({}, " ", {
      title = cmd,
      lines = lines,
      efm = vim.api.nvim_buf_get_option(bufnr, "errorformat"),
    })
    vim.api.nvim_command "doautocmd QuickFixCmdPost"
    if true and #lines > 0 then
      -- TODO: if some option is set
      vim.api.nvim_command "botright copen"
    end
  end

  local function on_stdout(_, data)
    if data then
      vim.api.nvim_buf_set_lines(output_bufnr, -1, -1, false, data)
    end
  end

  local function on_stderr(_, data)
    if data then
      vim.list_extend(lines, data)
    end
  end

  vim.fn.jobstart(cmd, {
    on_stderr = on_stderr,
    on_stdout = on_stdout,
    on_exit = on_exit,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

return M
