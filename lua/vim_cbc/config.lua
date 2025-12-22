-- config.lua - 配置管理模块
local M = {}

-- 默认配置
M.defaults = {
  width = 0.5,                -- 窗口宽度（0-1为百分比，>1为绝对列数）
  position = 'right',         -- 位置：'right' 或 'left'
  command = 'codebuddy-code', -- 执行的命令
  auto_insert = true,         -- 打开时是否自动进入插入模式
  close_on_exit = false       -- 命令退出时是否关闭终端
}

-- 当前配置（合并用户配置后）
M.options = vim.deepcopy(M.defaults)

-- 设置配置
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
end

-- 获取配置项
function M.get(key)
  return M.options[key]
end

return M
