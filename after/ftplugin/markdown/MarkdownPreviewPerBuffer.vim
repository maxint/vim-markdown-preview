command! -buffer MarkdownPreview :call MarkdownPreview#OpenBrowser()
command! -buffer MarkdownPreviewIfNeeded :call MarkdownPreview#OpenBrowserIfNeeded()
nnoremap <buffer> <leader>p :MarkdownPreviewIfNeeded<CR>
nnoremap <buffer> <leader>P :MarkdownPreview<CR>

if g:markdown_preview_autostart
    augroup MarkdownPreview
        au BufEnter     <buffer> call MarkdownPreview#EnterBuffer()
        if g:markdown_preview_slow
            au BufWrite,InsertLeave <buffer> call MarkdownPreview#DoIfNeeded()
        else
            au CursorMoved,CursorMovedI <buffer> call MarkdownPreview#DoIfNeeded()
        endif
    augroup END
else
    command! -buffer MarkdownPreviewUpdate :call MarkdownPreview#Do()
    nnoremap <buffer> <F5> :MarkdownPreviewUpdate<CR>
endif
