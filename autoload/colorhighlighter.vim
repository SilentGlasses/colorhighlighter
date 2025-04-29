" colorhighlighter.vim - Highlight color codes with their actual colors
" Author: SilentGlasses
" Version: 1.0
" Last Modified: 2025-04-29
" Description: Vim plugin that highlights color codes in their actual colors
" Compatibility: Vim 9.1 and above

" Script variables to track state
let s:found_colors = {}
let s:active_matches = {}

" Check if the current filetype should be highlighted
function! colorhighlighter#CheckFiletype() abort
  let l:filetype = &filetype

  " Check excluded filetypes first
  if exists('g:colorhighlighter_excluded_filetypes') && 
        \ !empty(g:colorhighlighter_excluded_filetypes) && 
        \ index(g:colorhighlighter_excluded_filetypes, l:filetype) >= 0
    call colorhighlighter#Disable()
    return 0
  endif

  " Then check included filetypes
  if exists('g:colorhighlighter_filetypes')
    let l:included = g:colorhighlighter_filetypes
  elseif exists('g:colorhighlighter_included_filetypes')
    let l:included = g:colorhighlighter_included_filetypes
  else
    let l:included = ['css', 'scss', 'sass', 'less', 'html', 'javascript', 'typescript']
  endif

  if empty(l:included) || index(l:included, l:filetype) >= 0
    call colorhighlighter#Enable()
    return 1
  endif

  " Disable if not included
  call colorhighlighter#Disable()
  return 0
endfunction

" Enable color highlighting for current buffer
function! colorhighlighter#Enable() abort
  " If highlighting is already enabled for this buffer, do nothing
  if exists('b:colorhighlighter_enabled') && b:colorhighlighter_enabled
    return
  endif

  " Flag this buffer as enabled
  let b:colorhighlighter_enabled = 1
  
  " Initialize active matches for this buffer
  if !exists('w:colorhighlighter_matches')
    let w:colorhighlighter_matches = []
  endif

  " Set up autocommands for this buffer
  augroup ColorHighlighter
    autocmd! * <buffer>
    autocmd BufEnter,BufWritePost <buffer> call colorhighlighter#HighlightColors()
    autocmd ColorScheme <buffer> call colorhighlighter#HighlightColors()
  augroup END

  " Initial highlighting
  call colorhighlighter#HighlightColors()
endfunction

" Disable color highlighting for current buffer
function! colorhighlighter#Disable() abort
  " If highlighting is already disabled for this buffer, do nothing
  if !exists('b:colorhighlighter_enabled') || !b:colorhighlighter_enabled
    return
  endif

  " Clear any active matches
  if exists('w:colorhighlighter_matches')
    for match_id in w:colorhighlighter_matches
      try
        call matchdelete(match_id)
      catch /E803:/
        " Match ID not found, ignore
      endtry
    endfor
    let w:colorhighlighter_matches = []
  endif

  " Clean up highlight groups
  let l:prefix = exists('g:colorhighlighter_hl_prefix') ? 
        \ g:colorhighlighter_hl_prefix : 'ColorHL_'
  for group in keys(s:GetExistingGroups(l:prefix))
    execute 'highlight clear ' . group
  endfor

  " Clean up
  let b:colorhighlighter_enabled = 0

  " Remove autocommands
  augroup ColorHighlighter
    autocmd! * <buffer>
  augroup END
endfunction

" Toggle the plugin on/off for the current buffer
function! colorhighlighter#Toggle() abort
  if exists('b:colorhighlighter_enabled') && b:colorhighlighter_enabled
    call colorhighlighter#Disable()
    echo "ColorHighlighter disabled"
  else
    call colorhighlighter#Enable()
    echo "ColorHighlighter enabled"
  endif
endfunction

" Clean up all highlights globally
function! colorhighlighter#Cleanup() abort
  " Remove all autocommands
  augroup ColorHighlighter
    autocmd!
  augroup END
  
  " Clear matches in all windows/buffers
  for bufnr in range(1, bufnr('$'))
    if bufexists(bufnr) && getbufvar(bufnr, 'colorhighlighter_enabled', 0)
      call setbufvar(bufnr, 'colorhighlighter_enabled', 0)
    endif
  endfor
  
  " Clear all highlight groups
  let l:prefix = exists('g:colorhighlighter_hl_prefix') ? 
        \ g:colorhighlighter_hl_prefix : 'ColorHL_'
  for group in keys(s:GetExistingGroups(l:prefix))
    execute 'highlight clear ' . group
  endfor
  
  " Reset script variables
  let s:found_colors = {}
  let s:active_matches = {}
endfunction

" Main function to highlight colors in the current buffer
function! colorhighlighter#HighlightColors() abort
  " Skip if disabled for this buffer
  if !exists('b:colorhighlighter_enabled') || !b:colorhighlighter_enabled
    return
  endif

  " Initialize window-local match list if needed
  if !exists('w:colorhighlighter_matches')
    let w:colorhighlighter_matches = []
  else
    " Clear existing matches
    for match_id in w:colorhighlighter_matches
      try
        call matchdelete(match_id)
      catch /E803:/
        " Match ID not found, ignore
      endtry
    endfor
    let w:colorhighlighter_matches = []
  endif

  " Reset found colors for this run
  let s:found_colors = {}
  
  " Define color patterns to match
  let hex_pattern = '#\x\{3,8\}\>'
  let rgb_pattern = 'rgba\?\s*(\s*\d\+\%(\.\d\+\)\?\s*,\s*\d\+\%(\.\d\+\)\?\s*,\s*\d\+\%(\.\d\+\)\?\s*\%(,\s*[0-9.]\+\s*\)\?\s*)'
  let hsl_pattern = 'hsla\?\s*(\s*\d\+\%(\.\d\+\)\?\s*,\s*\d\+\%(\.\d\+\)\?\s*%\s*,\s*\d\+\%(\.\d\+\)\?\s*%\s*\%(,\s*[0-9.]\+\s*\)\?\s*)'
  
  " Set up named color pattern if available
  let named_pattern = ''
  if exists('g:colorhighlighter_named_colors') && !empty(g:colorhighlighter_named_colors)
    let named_pattern = '\<\(' . join(keys(g:colorhighlighter_named_colors), '\|') . '\)\>'
  endif

  " Find colors in the current buffer
  let hex_colors = s:FindColorsInBuffer(hex_pattern, 'hex')
  let rgb_colors = s:FindColorsInBuffer(rgb_pattern, 'rgb')
  let hsl_colors = s:FindColorsInBuffer(hsl_pattern, 'hsl')
  let named_colors = !empty(named_pattern) ? 
        \ s:FindColorsInBuffer(named_pattern, 'named') : []

  " Apply highlighting for each color
  for [color_text, color_hex] in hex_colors + rgb_colors + hsl_colors + named_colors
    call s:ApplyColorHighlight(color_text, color_hex)
  endfor
endfunction

" List all detected colors in the current buffer
function! colorhighlighter#ListColors() abort
  " Make sure colors are highlighted first
  call colorhighlighter#HighlightColors()
  
  " Check if we found any colors
  if empty(s:found_colors)
    echo "No colors found in current buffer"
    return []
  endif
  
  " Get list of colors and sort them
  let color_list = sort(keys(s:found_colors))
  
  " Display them
  echo "Colors found in current buffer:"
  for color in color_list
    echo "  " . s:found_colors[color] . " -> " . color
  endfor
  
  return color_list
endfunction

" ======== Internal utility functions ========

" Find all colors in the current buffer matching the pattern
function! s:FindColorsInBuffer(pattern, type) abort
  let results = []
  if empty(a:pattern)
    return results
  endif

  let save_cursor = getcurpos()
  let save_view = winsaveview()
  
  " Move to start of buffer
  call cursor(1, 1)
  
  " Find all matches
  while 1
    let match_pos = search(a:pattern, 'W')
    if match_pos == 0
      break
    endif
    
    let color_text = ''
    if a:type ==# 'named'
      let color_text = expand('<cword>')
    else
      let color_text = matchstr(getline('.'), a:pattern, col('.') - 1)
    endif
    
    if !empty(color_text)
      " Convert to hex color value
      let color_hex = s:GetColorHex(color_text, a:type)
      if !empty(color_hex)
        call add(results, [color_text, color_hex])
      endif
    endif
  endwhile
  
  " Restore cursor position
  call setpos('.', save_cursor)
  call winrestview(save_view)
  
  return results
endfunction

" Apply highlighting for a specific color using matchadd
function! s:ApplyColorHighlight(color_text, color_hex) abort
  " Get the highlight group prefix
  let l:prefix = exists('g:colorhighlighter_hl_prefix') ? 
        \ g:colorhighlighter_hl_prefix : 'ColorHL_'
  
  " Create a sanitized group name based on the hex color
  let group_name = l:prefix . substitute(a:color_hex[1:], '[^0-9a-zA-Z]', '_', 'g')
  
  " Record the color text
  let s:found_colors[a:color_hex] = a:color_text
  
  " Only define highlight group if not already defined
  let highlight_exists = hlexists(group_name)
  if !highlight_exists
    " Determine if text should be white or black based on background color
    let [r, g, b] = s:HexToRgb(a:color_hex)
    let text_color = s:ShouldUseWhiteText(r, g, b) ? '#ffffff' : '#000000'
    
    " Define the highlight group
    execute 'highlight ' . group_name . ' guibg=' . a:color_hex . ' guifg=' . text_color . ' gui=NONE'
  endif
  
  " Escape special characters in the color text for regex
  let pattern = '\c' . escape(a:color_text, '\/.*$^~[]')
  
  " Apply highlighting with matchadd and store the match ID
  let match_id = matchadd(group_name, pattern, 100)
  call add(w:colorhighlighter_matches, match_id)
endfunction

" Get all existing highlight groups with a prefix
function! s:GetExistingGroups(prefix) abort
  redir => highlight_output
  silent! highlight
  redir END
  
  let groups = {}
  for line in split(highlight_output, "\n")
    if line =~ '^' . a:prefix
      let group_name = matchstr(line, '^' . a:prefix . '[^ ]*')
      let groups[group_name] = 1
    endif
  endfor
  
  return groups
endfunction

" Convert various color formats to hex
function! s:GetColorHex(color_str, type) abort
  try
    if a:type ==# 'hex'
      return s:NormalizeHexColor(a:color_str)
    elseif a:type ==# 'rgb'
      return s:ParseRgb(a:color_str)
    elseif a:type ==# 'hsl'
      return s:ParseHsl(a:color_str)
    elseif a:type ==# 'named' && exists('g:colorhighlighter_named_colors')
      return get(g:colorhighlighter_named_colors, tolower(a:color_str), '')
    endif
  catch
    " If parsing fails, return empty string
    return ''
  endtry
  return ''
endfunction

" Normalize hex color format (#RGB -> #RRGGBB, etc.)
function! s:NormalizeHexColor(hex) abort
  " Extract hex digits only
  let hex = substitute(a:hex, '^#', '', '')
  
  " Convert short form #RGB to #RRGGBB
  if len(hex) == 3
    let r = hex[0]
    let g = hex[1]
    let b = hex[2]
    let hex = r . r . g . g . b . b
  elseif len(hex) == 4  " #RGBA -> #RRGGBB (ignore alpha)
    let r = hex[0]
    let g = hex[1]
    let b = hex[2]
    let hex = r . r . g . g . b . b
  elseif len(hex) == 8  " #RRGGBBAA -> #RRGGBB (ignore alpha)
    let hex = hex[0:5]
  endif
  
  " Return standardized format (ensure we have at least 6 characters)
  if len(hex) >= 6
    return '#' . tolower(hex[0:5])
  endif
  
  " If we reach here, the format was invalid
  return ''
endfunction

" Parse RGB color format to hex
function! s:ParseRgb(rgb_str) abort
  " Extract the RGB values using regex
  let rgb = matchlist(a:rgb_str, 'rgba\?\s*(\s*\(\d\+\%(\.\d\+\)\?\)\s*,\s*\(\d\+\%(\.\d\+\)\?\)\s*,\s*\(\d\+\%(\.\d\+\)\?\)\s*\%(,\s*[0-9.]\+\s*\)\?\s*)')
  
  if len(rgb) >= 4
    " Convert to integer values
    let r = float2nr(str2float(rgb[1]))
    let g = float2nr(str2float(rgb[2]))
    let b = float2nr(str2float(rgb[3]))
    
    " Ensure values are within valid range
    let r = max([0, min([255, r])])
    let g = max([0, min([255, g])])
    let b = max([0, min([255, b])])
    
    return printf('#%02x%02x%02x', r, g, b)
  endif
  return ''
endfunction

" Parse HSL color format to hex
function! s:ParseHsl(hsl_str) abort
  " Extract the HSL values using regex
  let hsl = matchlist(a:hsl_str, 'hsla\?\s*(\s*\(\d\+\%(\.\d\+\)\?\)\s*,\s*\(\d\+\%(\.\d\+\)\?\)\s*%\s*,\s*\(\d\+\%(\.\d\+\)\?\)\s*%\s*\%(,\s*[0-9.]\+\s*\)\?\s*)')
  
  if len(hsl) >= 4
    " Convert to normalized values
    let h = str2float(hsl[1]) / 360.0
    let s = str2float(hsl[2]) / 100.0
    let l = str2float(hsl[3]) / 100.0
    
    " Convert HSL to RGB
    let [r, g, b] = s:HslToRgb(h, s, l)
    
    " Convert to hex
    return printf('#%02x%02x%02x', r, g, b)
  endif
  return ''
endfunction

" Convert HSL to RGB
function! s:HslToRgb(h, s, l) abort
  let h = a:h
  let s = a:s
  let l = a:l
  
  if s == 0.0
    " Achromatic (grey)
    let r = l * 255.0
    let g = l * 255.0
    let b = l * 255.0
    return [float2nr(round(r)), float2nr(round(g)), float2nr(round(b))]
  endif
  
  let q = l < 0.5 ? l * (1.0 + s) : l + s - l * s
  let p = 2.0 * l - q
  
  let r = s:HueToRgb(p, q, h + 1.0/3.0) * 255.0
  let g = s:HueToRgb(p, q, h) * 255.0
  let b = s:HueToRgb(p, q, h - 1.0/3.0) * 255.0
  
  return [float2nr(round(r)), float2nr(round(g)), float2nr(round(b))]
endfunction

" Helper function for HSL to RGB conversion
function! s:HueToRgb(p, q, t) abort
  let t = a:t
  
  if t < 0.0
    let t += 1.0
  endif
  if t > 1.0
    let t -= 1.0
  endif
  
  if t < 1.0/6.0
    return a:p + (a:q - a:p) * 6.0 * t
  elseif t < 1.0/2.0
    return a:q
  elseif t < 2.0/3.0
    return a:p + (a:q - a:p) * (2.0/3.0 - t) * 6.0
  endif
  
  return a:p
endfunction

" Convert hex color to RGB components
function! s:HexToRgb(hex_color) abort
  " Remove leading # if present
  let color = substitute(a:hex_color, '^#', '', '')
  
  " Handle different formats
  if len(color) == 3
    " #RGB format
    let r = str2nr(color[0] . color[0], 16)
    let g = str2nr(color[1] . color[1], 16)
    let b = str2nr(color[2] . color[2], 16)
    return [r, g, b]
  elseif len(color) >= 6
    " #RRGGBB format
    let r = str2nr(color[0:1], 16)
    let g = str2nr(color[2:3], 16)
    let b = str2nr(color[4:5], 16)
    return [r, g, b]
  endif
  
  " Default fallback
  return [0, 0, 0]
endfunction

" Determine if white text should be used on the given color
function! s:ShouldUseWhiteText(r, g, b) abort
  " Calculate relative luminance using the formula
  " L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  " where R, G, and B are normalized to [0, 1]
  let r_norm = a:r / 255.0
  let g_norm = a:g / 255.0
  let b_norm = a:b / 255.0
  
  " Calculate luminance
  let luminance = 0.2126 * r_norm + 0.7152 * g_norm + 0.0722 * b_norm
  
  " If luminance is less than 0.5, use white text, otherwise use black text
  return luminance < 0.5
endfunction
