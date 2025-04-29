" ColorHighlighter - Highlight color codes with their actual colors
" Author: SilentGlasses
" Version: 1.0.1
" Last Modified: 2025-04-29
" Description: Vim plugin that highlights color codes in their actual colors
" Compatibility: Vim 8.0 and above

" Version check
if v:version < 800
  echoerr 'ColorHighlighter requires Vim 8.0 or later'
  finish
endif

" Documentation file path
let s:doc_path = expand('<sfile>:p:h') . '/../doc/colorhighlighter.txt'

" Generate help tags if file exists
if filereadable(s:doc_path)
  silent! execute 'helptags ' . fnameescape(expand('<sfile>:p:h') . '/../doc')
endif

" Prevent loading multiple times
if exists('g:loaded_colorhighlighter')
  finish
endif

" Feature detection
let s:has_termguicolors = has('termguicolors')

" Set default options if not already set
if !exists('g:colorhighlighter_hl_prefix')
  let g:colorhighlighter_hl_prefix = 'ColorHL_'
endif

" Consolidated filetypes configuration
if !exists('g:colorhighlighter_filetypes')
  let g:colorhighlighter_filetypes = [
        \ 'css', 'scss', 'sass', 'less', 'stylus', 
        \ 'html', 'javascript', 'typescript', 
        \ 'jsx', 'tsx', 'json', 'yaml'
        \ ] 
endif

" Support for legacy configuration
if exists('g:colorhighlighter_included_filetypes') && !exists('g:colorhighlighter_filetypes')
  let g:colorhighlighter_filetypes = g:colorhighlighter_included_filetypes
endif

" Excluded filetypes
if !exists('g:colorhighlighter_excluded_filetypes')
  let g:colorhighlighter_excluded_filetypes = []
endif

" Extended named colors support
if !exists('g:colorhighlighter_named_colors')
  let g:colorhighlighter_named_colors = {
        \ 'black': '#000000',
        \ 'white': '#ffffff',
        \ 'red': '#ff0000',
        \ 'green': '#008000',
        \ 'blue': '#0000ff',
        \ 'yellow': '#ffff00',
        \ 'orange': '#ffa500',
        \ 'purple': '#800080',
        \ 'pink': '#ffc0cb',
        \ 'gray': '#808080',
        \ 'grey': '#808080'
        \ }
endif

" Highlight style configuration
if !exists('g:colorhighlighter_hl_styles')
  let g:colorhighlighter_hl_styles = {}
endif

" Create user commands with improved naming
command! -nargs=0 ColorHighlight call colorhighlighter#HighlightColors()
command! -nargs=0 ColorHighlightToggle call colorhighlighter#Toggle()
command! -nargs=0 ColorHighlightEnable call colorhighlighter#Enable()
command! -nargs=0 ColorHighlightDisable call colorhighlighter#Disable()
command! -nargs=0 ColorHighlightList call colorhighlighter#ListColors()
command! -nargs=0 ColorHighlightClean call colorhighlighter#Cleanup()

" Initialize the plugin with proper autocmds
augroup ColorHighlighterInit
  autocmd!
  autocmd FileType * call colorhighlighter#CheckFiletype()
  autocmd BufEnter * call colorhighlighter#CheckFiletype()
  autocmd VimLeave * call colorhighlighter#Cleanup()
augroup END

" Add real-time update events with debouncing
if !exists('g:colorhighlighter_update_delay')
  let g:colorhighlighter_update_delay = 500 " milliseconds
endif

augroup ColorHighlighterRealTime
  autocmd!
  " Update on text changes with debouncing to avoid performance issues
  autocmd TextChanged,TextChangedI,TextChangedP * call s:DebounceHighlightCall()
augroup END

" Debouncing function to prevent excessive processing during typing
let s:highlighter_timer = -1
function! s:DebounceHighlightCall() abort
  " Only proceed if the current buffer has highlighting enabled
  if !exists('b:colorhighlighter_enabled') || !b:colorhighlighter_enabled
    return
  endif

  " Cancel previous timer if it exists
  if s:highlighter_timer != -1
    call timer_stop(s:highlighter_timer)
  endif

  " Set a new timer
  let s:highlighter_timer = timer_start(g:colorhighlighter_update_delay, 
        \ {timer -> execute('call colorhighlighter#HighlightColors()')})
endfunction

" Control whether to enable by default
if !exists('g:colorhighlighter_enable')
  let g:colorhighlighter_enable = 1
endif

" Initial setup if enabled by default
if g:colorhighlighter_enable
  call colorhighlighter#CheckFiletype()
endif

" Mark as loaded
let g:loaded_colorhighlighter = 1
