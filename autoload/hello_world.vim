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
  call s:assure_hello_world_collection()

  let head = tolower(a:lang[0])
  " Check if the head character is [a-z]
  let head = 97 <= char2nr(head) && char2nr(head) <= 122 ? head : '#'
  let glob = s:validate_path(g:hello_world_dir).'/'.head.'/'.a:lang.'*'
  let files = split(expand(glob), '\n')
  exe g:hello_world_window_height.'split '.files[0]
  setlocal readonly
  setlocal nomodifiable
  setlocal bufhidden=delete
  nnoremap q :<c-u>quit<cr>
endfu

fu! hello_world#update()
  let dir = s:validate_path(g:hello_world_dir)
  if isdirectory(dir)
    let cwd = getcwd()
    " There are some ways to execute Git commands outside the repository, but
    " they depend on the version and version detection is not easy.
    " See http://stackoverflow.com/questions/5083224/git-pull-while-not-in-a-git-directory and others
    " git --git-dir=~/foo/.git --work-tree=~/foo status
    " git -C ~/foo status (since Git 2.3.4, March 2015)
    call s:cd_or_lcd(dir)
    call system('git pull origin master')
    call s:cd_or_lcd(cwd)
  else
    let cmd = 'git clone '.s:hello_world_url
    call system(cmd.' '.dir)
  endif
endfu

fu! hello_world#complete(A, L, P)
  return filter(hello_world#list(), 'v:val =~ "^".a:A')
endfu

fu! hello_world#list()
  " nr2char(97) == 'a'
  " nr2char(122) == 'z'
  let dirs = ['#'] + map(range(97, 122), 'nr2char(v:val)')
  let result = []
  for dir in dirs
    let glob = dir.'/*'
    call extend(result, s:list(glob))
  endfor
  return result
endfu

fu! s:list(glob)
  call s:assure_hello_world_collection()

  let dir = s:validate_path(g:hello_world_dir)
  let list = split(globpath(dir, a:glob), '\n')
  call map(list, 'fnamemodify(v:val, ":t:r")')
  return list
endfu

fu! s:cd_or_lcd(dir)
  if haslocaldir()
    exe 'lcd '.a:dir
  else
    exe 'cd '.a:dir
  endif
endfu

fu! s:validate_path(path)
  return substitute(fnamemodify(a:path, ':p'), '\v/+$', '', '')
endfu

fu! s:assure_hello_world_collection()
  let dir = s:validate_path(g:hello_world_dir)
  " Clone the hello-world collection if not exists
  if !isdirectory(dir)
    call hello_world#update()
  endif
endfu

let &cpo = s:save_cpo
unlet s:save_cpo
