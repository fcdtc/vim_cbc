-- window.lua - 窗口管理模块
local config = require('vim_cbc.config')
local M = {}

-- 计算窗口宽度
local function calculate_width(config_width)
  if config_width > 0 and config_width < 1 then
    -- 百分比模式：0-1 之间表示占屏幕的百分比
    return math.floor(vim.o.columns * config_width)
  else
    -- 绝对值模式：>1 表示固定列数
    return math.floor(config_width)
  end
end

-- 创建垂直分屏窗口
-- @param width number: 窗口宽度（配置值）
-- @param position string: 位置 ('right' 或 'left')
-- @param buf number: buffer ID
-- @return number: 窗口 ID
function M.create_split(width, position, buf)
  -- 保存当前窗口，以便后续返回
  local previous_win = vim.api.nvim_get_current_win()

  -- 计算实际宽度
  local actual_width = calculate_width(width)

  -- 根据位置创建分屏
  if position == 'left' then
    vim.cmd('topleft vsplit')
  else
    vim.cmd('botright vsplit')
  end

  -- 设置窗口宽度
  vim.cmd('vertical resize ' .. actual_width)

  -- 获取新窗口 ID
  local win = vim.api.nvim_get_current_win()

  -- 将 buffer 设置到新窗口
  if buf then
    vim.api.nvim_win_set_buf(win, buf)
  end

  return win, previous_win
end

-- 关闭指定窗口
-- @param win_id number: 窗口 ID
function M.close(win_id)
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_win_close(win_id, false)
  end
end

-- 跳转到指定窗口
-- @param win_id number: 窗口 ID
function M.focus(win_id)
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_set_current_win(win_id)
    return true
  end
  return false
end

return M
