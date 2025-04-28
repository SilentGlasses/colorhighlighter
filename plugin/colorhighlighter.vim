" Only load once
if exists('g:loaded_colorhighlighter')
  finish
endif
let g:loaded_colorhighlighter = 1

" Configuration variables
let g:colorhighlighter_filetypes = 
      \ get(g:, 'colorhighlighter_filetypes',
      \ ['css','scss','sass','less','stylus','html','javascript','typescript','jsx','tsx','json','yaml'])

" Initialize
if !exists('g:colorhighlighter_enable') || g:colorhighlighter_enable
  runtime! autoload/colorhighlighter.vim
  call colorhighlighter#Enable()
endif

" plugin/colorpreview.vim
if exists('g:loaded_colorpreview')
  finish
endif
let g:loaded_colorpreview = 1

function! s:hex_to_rgb(hex)
  let hex = substitute(a:hex, '#', '', '')
  if strlen(hex) == 3
    let r = str2nr(repeat(strpart(hex, 0, 1), 2), 16)
    let g = str2nr(repeat(strpart(hex, 1, 1), 2), 16)
    let b = str2nr(repeat(strpart(hex, 2, 1), 2), 16)
  else
    let r = str2nr(strpart(hex, 0, 2), 16)
    let g = str2nr(strpart(hex, 2, 2), 16)
    let b = str2nr(strpart(hex, 4, 2), 16)
  endif
  return [r, g, b]
endfunction

function! s:rgb_to_hex(r, g, b)
  return printf('#%02x%02x%02x', a:r, a:g, a:b)
endfunction

function! s:parse_rgb(match)
  let m = matchlist(a:match, '\vrgba?\((\s*\d+)\s*,(\s*\d+)\s*,(\s*\d+)[^)]*\)')
  if len(m) >= 4
    return s:rgb_to_hex(str2nr(m[1]), str2nr(m[2]), str2nr(m[3]))
  endif
  return ''
endfunction

function! s:parse_hsl(match)
  let m = matchlist(a:match, '\vhsla?\((\d+),\s*(\d+)%?,\s*(\d+)%?[^)]*\)')
  if len(m) >= 4
    let h = str2float(m[1]) / 360.0
    let s = str2float(m[2]) / 100.0
    let l = str2float(m[3]) / 100.0

    if s == 0
      let r = g = b = l
    else
      let q = l < 0.5 ? l * (1 + s) : l + s - l * s
      let p = 2 * l - q
      function! Hue2RGB(p, q, t)
        if a:t < 0 | let a:t += 1 | endif
        if a:t > 1 | let a:t -= 1 | endif
        if a:t < 1/6.0 | return a:p + (a:q - a:p) * 6 * a:t | endif
        if a:t < 1/2.0 | return a:q | endif
        if a:t < 2/3.0 | return a:p + (a:q - a:p) * (2/3.0 - a:t) * 6 | endif
        return a:p
      endfunction
      let r = Hue2RGB(p, q, h + 1/3.0)
      let g = Hue2RGB(p, q, h)
      let b = Hue2RGB(p, q, h - 1/3.0)
    endif

    return s:rgb_to_hex(float2nr(r * 255), float2nr(g * 255), float2nr(b * 255))
  endif
  return ''
endfunction

function! s:HighlightColors()
  if exists('w:color_matches')
    for id in w:color_matches
      call matchdelete(id)
    endfor
  endif
  let w:color_matches = []

  let lines = getline(1, '$')
  let patterns = [
        \ ['#\x\{3,6\}\>', 'hex'],
        \ ['rgba\?([^)]\+)', 'rgb'],
        \ ['hsla\?([^)]\+)', 'hsl']
        \ ]

  for lnum in range(len(lines))
    let line = lines[lnum]
    for [pattern, type] in patterns
      let start = 0
      while match(line, pattern, start) >= 0
        let col = match(line, pattern, start)
        let match_str = matchstr(line, pattern, start)
        let color = ''

        if type ==# 'hex'
          let color = match_str
        elseif type ==# 'rgb'
          let color = s:parse_rgb(match_str)
        elseif type ==# 'hsl'
          let color = s:parse_hsl(match_str)
        endif

        if color !=# ''
          let hl_group = 'Color_' . substitute(color, '#', '', '')
          if !hlexists(hl_group)
            execute 'highlight ' . hl_group . ' guibg=' . color . ' guifg=' . (color ==# '#000000' ? '#ffffff' : '#000000')
          endif
          let match_id = matchaddpos(hl_group, [[lnum + 1, col + 1, strlen(match_str)]])
          call add(w:color_matches, match_id)
        endif
        let start = col + strlen(match_str)
      endwhile
    endfor
  endfor
endfunction

augroup ColorPreview
  autocmd!
  autocmd BufEnter,BufReadPost,TextChanged,TextChangedI
        \ *.css,*.scss,*.html,*.js,*.ts,*.json,*.yaml,*.yml,*.jsx,*.tsx
        \ call s:HighlightColors()
augroup END

