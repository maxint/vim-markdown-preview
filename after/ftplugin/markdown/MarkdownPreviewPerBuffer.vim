command! -buffer MarkdownPreviewUpdate :call MarkdownPreview#Update()
command! -buffer MarkdownPreviewOpenBrowser :call MarkdownPreview#OpenBrowser()
nnoremap <buffer> <silent> <F5> :MarkdownPreviewUpdate<CR>

if g:markdown_preview_autostart
    augroup MarkdownPreview
        au!
        au BufEnter <buffer> call MarkdownPreview#Update()
        au BufLeave,BufUnload,BufDelete <buffer> call MarkdownPreview#Remove()
        if g:markdown_preview_slow
            au BufWrite,InsertLeave <buffer> call MarkdownPreview#UpdateIfNeeded()
        else
            au CursorMoved,CursorMovedI <buffer> call MarkdownPreview#UpdateIfNeeded()
        endif
    augroup END
endif
