" vim_cbc.vim - VimScript 插件入口（简化版）
" 防止重复加载
if exists('g:loaded_vim_cbc')
  finish
endif
let g:loaded_vim_cbc = 1

" 定义全局命令
command! CodebuddyToggle lua require('vim_cbc').toggle()
command! CodebuddyOpen lua require('vim_cbc').open()
command! CodebuddyClose lua require('vim_cbc').close()

" 设置快捷键映射
" <leader>..: 切换 Codebuddy 终端（保持会话）
noremap <silent> <leader>.. :lua require('vim_cbc').toggle()<CR>

" 简化说明：
" - 移除了 <C-h> 快捷键，依赖 Neovim 内置的终端导航
" - 移除了 <Esc><Esc> 快捷键，依赖 Neovim 标准终端行为
" - 在全屏模式下，使用 <leader>.. 切换标签页
" - 在分割模式下，使用 Neovim 内置的窗口导航（如 <C-w>w）

