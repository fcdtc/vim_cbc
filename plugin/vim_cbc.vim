" vim_cbc.vim - VimScript 插件入口
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
nnoremap <silent> <leader>.. :lua require('vim_cbc').toggle()<CR>

" <C-h>: 从终端模式返回编辑器窗口
" <C-\><C-n> 用于退出终端插入模式
tnoremap <silent> <C-h> <C-\><C-n>:lua require('vim_cbc').focus_editor()<CR>

" <Esc><Esc>: 退出终端插入模式到普通模式
tnoremap <silent> <Esc><Esc> <C-\><C-n>
