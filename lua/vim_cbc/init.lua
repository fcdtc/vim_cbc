-- init.lua - vim_cbc 插件主入口
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

-- 将焦点返回到编辑器
function M.focus_editor()
  terminal.focus_editor()
end

return M
