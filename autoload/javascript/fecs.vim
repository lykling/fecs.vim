" Copyright 2014 All rights reserved.
"
" fecs.vim: Vim command to check js files with fecs.
"
" This filetype plugin add a new commands for js buffers:
"
"   :FecsCheck
"
" Options:
"
"   g:fecs_command [default="fecs"]
"
"       Flag naming the fecs executable to use.
"
"   g:fecs_autosave [default=1]
"
"       Flag to auto call :FecsCheck when saved file
"
if !exists("g:fecs_command")
    let g:fecs_command = "fecs"
endif
if !exists("g:fecs_options")
    let g:fecs_options = ""
endif

let s:got_js_fmt_error = 0
function! javascript#fecs#Check()
    " save cursor position and many other things
    let l:curw=winsaveview()

    " Ignore json file
    if expand("%:e") == 'json'
        return 0
    endif

    " needed for testing if fecs fails or not
    " fecs will ignore files which name isn't end of .js
    " (TODO) add support for css file
    let l:tmpname=tempname() . "." . expand("%:e")
    call writefile(getline(1,'$'), l:tmpname)

    " save our undo file to be restored after we are done. This is needed to
    " prevent an additional undo jump due to BufWritePre auto command and also
    " restore 'redo' history because it's getting being destroyed every
    " BufWritePre
    let l:tmpundofile=tempname()
    exe 'wundo! ' . tmpundofile

    " populate the final command with user based fmt options
    let command = g:fecs_command . ' ' . g:fecs_options

    " execute our command...
    let out = system(command . " " . l:tmpname)

    "if there is no error on the temp file, fecs again our original file
    if v:shell_error == 0
        " remove undo point caused via BufWritePre
        try | silent undojoin | catch | endtry

        " (TODO) do somethind like format it self

        " only clear quickfix if it was previously set, this prevents closing
        " other quickfixes
        if s:got_js_fmt_error 
            let s:got_js_fmt_error = 0
            call setqflist([])
            cwindow
        endif
    else
        "otherwise get the errors and put them to quickfix window
        let errors = []
        for line in split(out, '\n')
            let tokens = matchlist(line, '^\(.\{-}\)line\s*\(\d\+\)\(,\s*col\s*\(\d\+\)\)*:\s*\(.*\)')
            if !empty(tokens)
                call add(errors, {"filename": @%,
                            \"lnum":     tokens[2],
                            \"col":      tokens[4],
                            \"text":     tokens[5]})
            endif
        endfor
        if empty(errors)
            % | " Couldn't detect fecs error format, output errors
        endif
        if !empty(errors)
            call setqflist(errors, 'r')
            echohl Error | echomsg "fecs returned error" | echohl None
        endif
        let s:got_js_fmt_error = 1
        cwindow
    endif

    " restore our undo history
    silent! exe 'rundo ' . tmpundofile
    call delete(l:tmpundofile)

    " restore our cursor/windows positions
    call delete(l:tmpname)
    call winrestview(l:curw)
endfunction


" vim:ts=4:sw=4:et
