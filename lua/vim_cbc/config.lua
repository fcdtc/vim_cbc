-- config.lua - 配置管理模块
local M = {}

-- 默认配置（简化版）
M.defaults = {
  mode = 'fullscreen',        -- 模式：'split' 或 'fullscreen'
  command = 'codebuddy-code', -- 执行的命令
  auto_insert = true,         -- 打开时是否自动进入插入模式
  close_on_exit = false       -- 命令退出时是否关闭终端
}

-- 当前配置（合并用户配置后）
M.options = vim.deepcopy(M.defaults)

-- 设置配置（支持向后兼容性）
function M.setup(opts)
  local user_opts = opts or {}

  -- 向后兼容性处理：如果用户提供了旧配置，自动转换
  if user_opts.position or user_opts.width then
    -- 检测到旧配置，自动设置为 split 模式
    user_opts.mode = 'split'

    -- 如果用户没有显式设置 mode，但提供了旧配置，发出警告
    if not opts.mode then
      vim.notify(
        "vim_cbc: 检测到旧配置（position/width），已自动设置为 split 模式。" ..
        "建议更新配置为使用 mode 选项。",
        vim.log.levels.WARN
      )
    end
  end

  M.options = vim.tbl_deep_extend('force', M.defaults, user_opts)
end

-- 获取配置项
function M.get(key)
  return M.options[key]
end

-- 检查是否为全屏模式
function M.is_fullscreen()
  return M.options.mode == 'fullscreen'
end

-- 检查是否为分割模式
function M.is_split()
  return M.options.mode == 'split'
end

return M
