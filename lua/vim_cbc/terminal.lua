-- terminal.lua - 终端管理核心模块（支持全屏模式）
local config = require('vim_cbc.config')
local window = require('vim_cbc.window')
local M = {}

-- 终端状态（简化版）
local state = {
  terminal_buf = nil,      -- terminal buffer ID
  terminal_win = nil,      -- terminal window ID
  job_id = nil,           -- job ID
  window_result = nil     -- 窗口创建结果（支持全屏和分割模式）
}

-- 检查终端是否可见
function M.is_visible()
  return state.terminal_win ~= nil and vim.api.nvim_win_is_valid(state.terminal_win)
end

-- 检查终端 buffer 是否存在
local function buffer_exists()
  return state.terminal_buf ~= nil and vim.api.nvim_buf_is_valid(state.terminal_buf)
end

-- 创建新的终端 buffer
local function create_terminal_buffer()
  local buf = vim.api.nvim_create_buf(false, true)

  -- 设置 buffer 选项
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')  -- 隐藏时不删除
  vim.api.nvim_buf_set_option(buf, 'buflisted', false)   -- 不在 buffer 列表中显示
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)    -- 不创建交换文件

  return buf
end

-- 打开终端
function M.open()
  -- 如果终端已经可见，直接返回
  if M.is_visible() then
    if config.get('auto_insert') then
      vim.cmd('startinsert')
    end
    return
  end

  -- 如果 buffer 不存在，创建新的
  if not buffer_exists() then
    state.terminal_buf = create_terminal_buffer()
  end

  -- 创建窗口（根据配置模式自动选择）
  state.window_result = window.create(state.terminal_buf)
  state.terminal_win = state.window_result.win_id

  -- 如果是新创建的 buffer（没有 job_id），启动终端
  if not state.job_id then
    local cmd = config.get('command')
    state.job_id = vim.fn.termopen(cmd, {
      on_exit = function(_, exit_code, _)
        if config.get('close_on_exit') then
          M.close()
        end
        state.job_id = nil
      end
    })

    -- 如果 termopen 失败
    if state.job_id <= 0 then
      vim.notify('Failed to start terminal with command: ' .. cmd, vim.log.levels.ERROR)
      M.close()
      return
    end
  end

  -- 设置窗口选项
  vim.api.nvim_win_set_option(state.terminal_win, 'number', false)
  vim.api.nvim_win_set_option(state.terminal_win, 'relativenumber', false)
  vim.api.nvim_win_set_option(state.terminal_win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(state.terminal_win, 'cursorline', false)
  vim.api.nvim_win_set_option(state.terminal_win, 'cursorcolumn', false)

  -- 如果配置了自动进入插入模式
  if config.get('auto_insert') then
    vim.cmd('startinsert')
  end
end

-- 隐藏终端窗口（但保留 buffer 和进程，用于 toggle）
local function hide()
  if M.is_visible() then
    -- 关闭窗口（根据模式自动处理）
    window.close(state.window_result)
    state.terminal_win = nil
    state.window_result = nil
  end
end

-- 完全关闭终端（终止进程并清理所有资源）
function M.close()
  -- 终止终端进程
  if state.job_id then
    vim.fn.jobstop(state.job_id)
    state.job_id = nil
  end

  -- 关闭窗口
  if M.is_visible() then
    window.close(state.window_result)
    state.terminal_win = nil
    state.window_result = nil
  end

  -- 删除 buffer
  if buffer_exists() then
    vim.api.nvim_buf_delete(state.terminal_buf, { force = true })
    state.terminal_buf = nil
  end
end

-- 切换终端显示/隐藏（保持会话）
function M.toggle()
  if M.is_visible() then
    hide()  -- 使用 hide 而不是 close，保持会话
  else
    M.open()
  end
end

-- 将焦点切回编辑器窗口（简化版）
function M.focus_editor()
  -- 在全屏模式下，使用 <leader>.. 切换回编辑器
  -- 在分割模式下，依赖 Neovim 内置的窗口导航
  -- 此函数主要用于向后兼容，实际使用中可能不需要
  if state.window_result and state.window_result.previous_win then
    window.focus(state.window_result.previous_win)
  else
    -- 如果无法找到上一个窗口，使用默认的窗口导航
    vim.cmd('wincmd p')
  end
end

return M
