let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_git_checkout_here')
  finish
endif

command! -nargs=0 GitCheckoutHere call git_checkout_here#checkoutHere()

let g:loaded_git_checkout_here = 1

let &cpo = s:save_cpo
unlet s:save_cpo
