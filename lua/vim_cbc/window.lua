-- window.lua - 窗口管理模块（支持全屏模式）
local config = require('vim_cbc.config')
local M = {}

-- 创建全屏窗口（新标签页方案）
-- @param buf number: buffer ID
-- @return table: {win_id, previous_tabpage, previous_layout}
function M.create_fullscreen(buf)
  -- 保存当前状态
  local previous_tabpage = vim.api.nvim_get_current_tabpage()
  local previous_layout = {
    tabpage = previous_tabpage,
    windows = vim.api.nvim_tabpage_list_wins(previous_tabpage)
  }

  -- 创建新标签页
  vim.cmd('tabnew')
  local new_tabpage = vim.api.nvim_get_current_tabpage()

  -- 获取当前窗口并最大化
  local win = vim.api.nvim_get_current_win()

  -- 设置 buffer
  if buf then
    vim.api.nvim_win_set_buf(win, buf)
  end

  return {
    win_id = win,
    previous_tabpage = previous_tabpage,
    previous_layout = previous_layout
  }
end

-- 创建分割窗口（向后兼容）
-- @param buf number: buffer ID
-- @return table: {win_id, previous_win}
function M.create_split(buf)
  -- 保存当前窗口
  local previous_win = vim.api.nvim_get_current_win()

  -- 创建右侧分屏（保持原有行为）
  vim.cmd('botright vsplit')

  -- 设置窗口宽度为屏幕的20%（保持原有默认值）
  local width = math.floor(vim.o.columns * 0.2)
  vim.cmd('vertical resize ' .. width)

  -- 获取新窗口
  local win = vim.api.nvim_get_current_win()

  -- 设置 buffer
  if buf then
    vim.api.nvim_win_set_buf(win, buf)
  end

  return {
    win_id = win,
    previous_win = previous_win
  }
end

-- 创建窗口（根据配置模式自动选择）
-- @param buf number: buffer ID
-- @return table: 窗口创建结果
function M.create(buf)
  if config.is_fullscreen() then
    return M.create_fullscreen(buf)
  else
    return M.create_split(buf)
  end
end

-- 关闭窗口（支持全屏和分割模式）
-- @param result table: 窗口创建结果
function M.close(result)
  if not result then return end

  if result.previous_tabpage then
    -- 全屏模式：关闭当前标签页，返回原标签页
    vim.cmd('tabclose')
    if vim.api.nvim_tabpage_is_valid(result.previous_tabpage) then
      vim.api.nvim_set_current_tabpage(result.previous_tabpage)
    end
  else
    -- 分割模式：关闭当前窗口，返回原窗口
    if result.win_id and vim.api.nvim_win_is_valid(result.win_id) then
      vim.api.nvim_win_close(result.win_id, false)
    end
    if result.previous_win and vim.api.nvim_win_is_valid(result.previous_win) then
      vim.api.nvim_set_current_win(result.previous_win)
    end
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

-- 检查窗口是否有效
function M.is_valid(win_id)
  return win_id and vim.api.nvim_win_is_valid(win_id)
end

return M
