let s:save_cpo = &cpoptions
set cpoptions&vim

if !exists('g:hello_world_dir')
  let g:hello_world_dir = '~/.hello-world'
endif
if !exists('g:hello_world_enable_shallow_clone')
  let g:hello_world_enable_shallow_clone = 1
endif
if !exists('g:hello_world_window_height')
  let g:hello_world_window_height = 12
endif

let s:hello_world_url = 'https://github.com/leachim6/hello-world'

fu! hello_world#hello_world(lang)
  call hello_world#update(v:true)

  let head = tolower(a:lang[0])
  " Check if the head character is [a-z]
  let head = 97 <= char2nr(head) && char2nr(head) <= 122 ? head : '#'
  let glob = printf('%s/%s/%s.*', s:validate_path(g:hello_world_dir), head, a:lang)
  let files = split(expand(glob), '\n')
  exe printf('%dsplit %s', g:hello_world_window_height, files[0])
  setlocal readonly
  setlocal nomodifiable
  setlocal bufhidden=delete
  nnoremap q :<c-u>quit<cr>
endfu

fu! hello_world#update(install_only)
  let dir = s:validate_path(g:hello_world_dir)
  if isdirectory(dir)
    call system(printf('git -C %s pull origin master', dir))
  elseif !a:install_only
    call system(printf('git clone %s %s', s:hello_world_url, dir))
  endif
endfu

fu! hello_world#complete(A, L, P)
  return filter(hello_world#list(), 'v:val =~ "^".a:A')
endfu

fu! hello_world#list()
  call hello_world#update(v:true)

  " nr2char(97) == 'a'
  " nr2char(122) == 'z'
  let dirs = ['#'] + map(range(97, 122), 'nr2char(v:val)')

  " Use dictionary to remove duplicated candidates
  let result = {}
  for dir in dirs
    let list = s:list(printf('%s/*', dir))
    for item in list
      let result[item] = 1
    endfor
  endfor
  return keys(result)
endfu

fu! s:list(glob)
  let dir = s:validate_path(g:hello_world_dir)
  let list = split(globpath(dir, a:glob), '\n')
  call map(list, 'fnamemodify(v:val, ":t:r")')
  return list
endfu

fu! s:validate_path(path)
  return substitute(fnamemodify(a:path, ':p'), '\v[\\/]+$', '', '')
endfu

let &cpo = s:save_cpo
unlet s:save_cpo
