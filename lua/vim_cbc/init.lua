-- init.lua - vim_cbc 插件主入口（简化版）
local config = require('vim_cbc.config')
local terminal = require('vim_cbc.terminal')

local M = {}

-- 插件初始化
-- @param opts table: 用户配置选项
function M.setup(opts)
  config.setup(opts)
end

-- 切换终端显示/隐藏
function M.toggle()
  terminal.toggle()
end

-- 打开终端
function M.open()
  terminal.open()
end

-- 关闭终端
function M.close()
  terminal.close()
end

-- 将焦点返回到编辑器（向后兼容，实际使用中可能不需要）
function M.focus_editor()
  terminal.focus_editor()
end

-- 检查终端是否可见
function M.is_visible()
  return terminal.is_visible()
end

-- 获取当前配置模式
function M.get_mode()
  return config.get('mode')
end

-- 检查是否为全屏模式
function M.is_fullscreen()
  return config.is_fullscreen()
end

-- 检查是否为分割模式
function M.is_split()
  return config.is_split()
end

return M
