" Setup:
"   $ brew install visidata

" VisiData in a full-window terminal, like tig in tig.vim: q in vd comes back to the buffer.
" :VisiData [file]  -> that file, else a data file path under the cursor, else the current one
" (as saved: vd reads it from disk)
let s:data_exts = ['csv', 'tsv', 'tab', 'psv', 'json', 'jsonl', 'ndjson', 'parquet', 'arrow', 'feather',
    \ 'xlsx', 'xls', 'ods', 'sqlite', 'sqlite3', 'db', 'duckdb', 'h5', 'hdf5', 'xml', 'yaml', 'yml', 'fixed', 'dta', 'sas7bdat', 'sav']

function! s:IsDataFile(file) abort
    " data.csv.gz -> csv: vd reads compressed files directly
    let l:name = substitute(a:file, '\c\.\(gz\|bz2\|xz\|zst\|zip\)$', '', '')
    return filereadable(a:file) && index(s:data_exts, tolower(fnamemodify(l:name, ':e'))) >= 0
endfunction

" Path under the cursor, as written or relative to the current file's folder
function! s:DataFileUnderCursor() abort
    let l:cfile = expand('<cfile>')
    if empty(l:cfile)
        return ''
    endif
    for l:file in [expand(l:cfile), expand('%:p:h') . '/' . l:cfile]
        if s:IsDataFile(l:file)
            return l:file
        endif
    endfor
    return ''
endfunction

function! s:VisiData(file) abort
    let l:file = a:file
    if empty(l:file)
        let l:file = s:DataFileUnderCursor()
    endif
    if empty(l:file)
        let l:file = expand('%')
        if !s:IsDataFile(l:file)
            echohl ErrorMsg | echo 'VisiData: no data file under the cursor, and not one: ' . l:file | echohl None
            return
        endif
    endif
    let l:file = fnamemodify(l:file, ':p')
    if !filereadable(l:file)
        echohl ErrorMsg | echo 'VisiData: no such file: ' . l:file | echohl None
        return
    endif
    let l:prev = bufnr()
    enew
    call termopen(['vd', l:file], {'on_exit': {-> execute('if bufexists(' . l:prev . ') | buffer ' . l:prev . ' | endif | silent! bwipeout! #')}})
    startinsert
endfunction
command! -nargs=? -complete=file VisiData call s:VisiData(<q-args>)

nnoremap tv :VisiData<CR>

echom 'Loaded ' . expand('<sfile>:t') |redraw
