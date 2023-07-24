local M = {}

M.opts = { colsize = 80, verbose = true, open_qflist = true }

function M.setup(opts)
	opts = opts and opts or {}
	M.opts = vim.tbl_extend("force", M.opts, opts)
	vim.api.nvim_create_user_command("PyMake", M.make, {})
end

function M.make()
	local lines = { "" }
	local winnr = vim.fn.win_getid()
	local bufnr = vim.api.nvim_win_get_buf(winnr)
	local bufname = vim.fn.expand("%:~:.")

	local makeprg = vim.api.nvim_buf_get_option(bufnr, "makeprg")
	if not makeprg then
		return
	end

	local cmd = vim.fn.expandcmd(makeprg)

	-- create/recall the output buffer
	local output_bufnr = vim.g["pymake_stdout_buffer"]

  -- check if the output buffer still exists
	local is_output_buffer_present = false
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(w) == output_bufnr then
			is_output_buffer_present = true
			break
		end
	end

	if not (output_bufnr and is_output_buffer_present) then
		local prev_win = vim.api.nvim_get_current_win()
		vim.api.nvim_command(string.format("%svsplit", M.opts.colsize))
		local win = vim.api.nvim_get_current_win()
		output_bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_win_set_buf(win, output_bufnr)
		vim.g["pymake_stdout_buffer"] = output_bufnr
		vim.api.nvim_set_current_win(prev_win)
	end
	vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, { bufname .. " output:" })

	local function on_exit()
		vim.fn.setqflist({}, " ", {
			title = cmd,
			lines = lines,
			efm = vim.api.nvim_buf_get_option(bufnr, "errorformat"),
		})
		vim.api.nvim_command("doautocmd QuickFixCmdPost")
		if M.opts.open_qflist and #lines > 0 then
			vim.api.nvim_command("botright copen")
		end
		if M.opts.verbose then
			vim.print("[pymake] job done")
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

	if M.opts.verbose then
		vim.print("[pymake] job started")
	end
end

return M
