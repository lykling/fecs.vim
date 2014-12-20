" autoload settings
if !exists('g:fecs_autosave')
    let g:fecs_autosave = 1
endif

if g:fecs_autosave
    autocmd BufWritePre <buffer> call javascript#fecs#Check()
endif

" vim:ts=4:sw=4:et
