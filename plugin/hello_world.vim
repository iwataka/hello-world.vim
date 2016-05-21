if &compatible || (exists('g:loaded_hello_world') && g:loaded_hello_world)
  finish
endif
let g:loaded_hello_world = 1

com! -nargs=1 -complete=customlist,hello_world#complete HelloWorld
      \ call hello_world#hello_world(<f-args>)
com! HelloWorldUpdate call hello_world#update()
