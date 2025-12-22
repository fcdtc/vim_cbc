-- terminal.lua - 终端管理核心模块
local config = require('vim_cbc.config')
local window = require('vim_cbc.window')
local M = {}

-- 终端状态
local state = {
  terminal_buf = nil,  -- terminal buffer ID
  terminal_win = nil,  -- terminal window ID
  job_id = nil,        -- job ID
  previous_win = nil   -- 上一个窗口 ID（用于返回编辑器）
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
  -- 创建新 buffer
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
    -- 如果配置了自动进入插入模式，则进入
    if config.get('auto_insert') then
      vim.cmd('startinsert')
    end
    return
  end

  -- 如果 buffer 不存在，创建新的
  if not buffer_exists() then
    state.terminal_buf = create_terminal_buffer()
  end

  -- 创建窗口
  local win, prev_win = window.create_split(
    config.get('width'),
    config.get('position'),
    state.terminal_buf
  )

  state.terminal_win = win
  state.previous_win = prev_win

  -- 如果是新创建的 buffer（没有 job_id），启动终端
  if not state.job_id then
    local cmd = config.get('command')
    state.job_id = vim.fn.termopen(cmd, {
      on_exit = function(_, exit_code, _)
        -- 终端退出时的处理
        if config.get('close_on_exit') then
          M.close()
        end
        -- 重置 job_id
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
  vim.api.nvim_win_set_option(win, 'number', false)
  vim.api.nvim_win_set_option(win, 'relativenumber', false)
  vim.api.nvim_win_set_option(win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(win, 'cursorline', false)  -- 禁用光标行高亮（去掉下划线）
  vim.api.nvim_win_set_option(win, 'cursorcolumn', false) -- 禁用光标列高亮

  -- 如果配置了自动进入插入模式
  if config.get('auto_insert') then
    vim.cmd('startinsert')
  end
end

-- 隐藏终端窗口（但保留 buffer 和进程，用于 toggle）
local function hide()
  if M.is_visible() then
    -- 如果当前在终端窗口中，先跳回上一个窗口
    if vim.api.nvim_get_current_win() == state.terminal_win then
      if state.previous_win and vim.api.nvim_win_is_valid(state.previous_win) then
        vim.api.nvim_set_current_win(state.previous_win)
      end
    end

    -- 关闭终端窗口
    window.close(state.terminal_win)
    state.terminal_win = nil
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
    -- 如果当前在终端窗口中，先跳回上一个窗口
    if vim.api.nvim_get_current_win() == state.terminal_win then
      if state.previous_win and vim.api.nvim_win_is_valid(state.previous_win) then
        vim.api.nvim_set_current_win(state.previous_win)
      end
    end

    window.close(state.terminal_win)
    state.terminal_win = nil
  end

  -- 删除 buffer
  if buffer_exists() then
    vim.api.nvim_buf_delete(state.terminal_buf, { force = true })
    state.terminal_buf = nil
  end

  -- 清理状态
  state.previous_win = nil
end

-- 切换终端显示/隐藏（保持会话）
function M.toggle()
  if M.is_visible() then
    hide()  -- 使用 hide 而不是 close，保持会话
  else
    M.open()
  end
end

-- 将焦点切回编辑器窗口
function M.focus_editor()
  if state.previous_win and vim.api.nvim_win_is_valid(state.previous_win) then
    window.focus(state.previous_win)
  else
    -- 如果上一个窗口无效，尝试找到第一个非终端窗口
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
      if win ~= state.terminal_win then
        window.focus(win)
        state.previous_win = win
        break
      end
    end
  end
end

return M
