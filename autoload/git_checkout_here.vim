let s:save_cpo = &cpo
set cpo&vim

function! git_checkout_here#checkoutHere()
  if !executable('git')
    echo "git has not installed yet on this environment"
    return
  endif

  let l:current_line = line('.')
  let l:diff_block_with_range = s:get_diff_block_with_range_by_git_diff()

  let l:cmd_input = ''
  for l:order in l:diff_block_with_range
    if l:order['start'] <= l:current_line && l:current_line <= l:order['end']
      let l:cmd_input = l:cmd_input . 'y\n'
      continue
    endif

    let l:cmd_input = l:cmd_input . 'n\n'
  endfor

  " Not include `y\n`
  if empty(matchstr(l:cmd_input, 'y\\n'))
    echo "Nothing to do"
    return
  endif

  if input('Check out here? (y/n) [n]: ') != 'y'
    redraw
    echo "Aborted"
    return
  endif

  let l:filename  = expand("%:p")
  let l:cmd_input = l:cmd_input . 'y\n' " for last confirmation of not staged

  " Execute `git checkout HEAD -p` command with no interactions
  call system('echo -e "' . l:cmd_input . '" | git checkout HEAD --patch ' . l:filename)

  edit " re-render
endfunction

function! s:get_diff_block_with_range_by_git_diff()
  let l:diff_block_with_range = []

  let l:diff = system("git diff")
  let l:lines = split(l:diff, '\n')
  for l:line in l:lines
    " Following regex extracts;
    "   @@ -10,5 +10,10 @@
    "             ~~~~~
    let l:range = matchstr(l:line, '^@@ -\d\+,\d\+ +\zs\d\+,\d\+\ze @@')
    if !l:range
      continue
    endif

    let l:range_line = split(l:range, ',')
    let l:start = l:range_line[0]
    let l:end   = l:start + l:range_line[1]
    if !l:start || !l:end
      continue
    endif

    call add(l:diff_block_with_range, {'start': l:start, 'end': l:end})
  endfor

  return l:diff_block_with_range
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
