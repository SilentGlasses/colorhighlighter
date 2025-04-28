" Main plugin functionality
function! colorhighlighter#Enable()
  augroup ColorHighlighter
    autocmd!
    autocmd BufEnter,BufReadPost,TextChanged,TextChangedI,ColorScheme
          \ *.css,*.scss,*.sass,*.less,*.styl,*.html,*.js,*.ts,*.jsx,*.tsx,*.json,*.yaml,*.yml
          \ call s:HighlightColors()
  augroup END
endfunction

command! -nargs=0 ColorHighlight call s:HighlightColors()
command! -nargs=0 ColorDebug call s:DebugColors()
