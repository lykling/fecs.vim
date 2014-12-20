if exists("g:fecs_loaded_commands")
    finish
endif
let g:fecs_loaded_commands = 1

command! -nargs=0 FecsCheck call javascript#fecs#Check()

" vim:ts=4:sw=4:et
