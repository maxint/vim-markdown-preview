if exists('g:loaded_markdown_preview') || &cp || version < 700
    finish
endif

if !has('python3') && !has('python')
    echohl WarningMsg
    echom  "Markdown-preview requires py >= 2.7 or any py3"
    echohl None
    finish
endif

if !exists('g:markdown_preview_autostart')
    let g:markdown_preview_autostart=1
endif

if !exists('g:markdown_preview_slow')
    let g:markdown_preview_slow=1
endif

if !exists('g:markdown_preview_frequency_ms')
    let g:markdown_preview_frequency_ms = 1000
endif

let s:SourcedFile=expand("<sfile>")

function! MarkdownPreview#Init()
python << EOF
import vim, os, sys

sourced_dir = os.path.realpath(os.path.dirname(vim.eval('s:SourcedFile')))

if 'markdown_preview_css' not in vim.vars:
    vim.vars['markdown_preview_css'] = os.path.join(sourced_dir, 'markdown-preview.css')
if 'markdown_preview_js' not in vim.vars:
    vim.vars['markdown_preview_js'] = os.path.join(sourced_dir, 'markdown-preview.js')

module_path = os.path.realpath(os.path.join(sourced_dir, '../../../pythonx'))
if not hasattr(vim, 'VIM_SPECIAL_PATH'):
    sys.path.append(module_path)

import mistune
import tempfile
import time

def markdown_preview_wrap_html(title, css, js, html):
    def fileurl(path):
        if os.path.isfile(path):
            return 'file:///' + path.replace('\\', '/')
        else:
            return path

    def wrap_css(path):
        if os.path.isfile(path):
            return '<style type="text/css">' + open(path).read() + '</style>'
        else:
            return '<link href="{}" ref="stylesheet" type="text/css"></link>'.format(path)

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>{}</title>
  {}
  <script src="{}" type="text/javascript"></script>
</head>
<body>
<div id="main">
{}
</div>
</body>
</html>
'''.format(title, wrap_css(css), fileurl(js), html)

def get_buffer_name():
    name = vim.current.buffer.name
    return os.path.basename(name) if name else "NoName.md"

def markdown_preview_enter_buffer():
    curbuf = vim.current.buffer
    html_path = os.path.join(tempfile.gettempdir(), get_buffer_name() + '.html')
    curbuf.vars['markdown_preview_path'] = html_path

def markdown_preview_generate():
    curbuf = vim.current.buffer
    text = '\n'.join(curbuf[:])
    title = '[Markdown Preview] ' + get_buffer_name()
    html = mistune.markdown(text)
    html = markdown_preview_wrap_html(title,
                                      vim.vars['markdown_preview_css'],
                                      vim.vars['markdown_preview_js'],
                                      html)
    with open(curbuf.vars['markdown_preview_path'], 'w') as f:
        f.write(html)
    curbuf.vars['markdown_preview_last_generated_time'] = time.time()

def markdown_preview_generate_after(seconds):
    curbuf = vim.current.buffer
    last_time = curbuf.vars['markdown_preview_last_generated_time']
    if time.time() - last_time > seconds:
        markdown_preview_generate()

def markdown_preview_open_browser():
    curbuf = vim.current.buffer
    curbuf.vars['markdown_preview_opened'] = 1
    url = curbuf.vars['markdown_preview_path']
    try:
        if os.name == 'nt':
            os.startfile(url)
        else:
            os.system('open "{}"'.format(url))
    except:
        print 'Please open "{}" in browser manually'.format(url)

EOF
endfunction


function! MarkdownPreview#EnterBuffer()
python << EOF
markdown_preview_enter_buffer()
markdown_preview_generate()
markdown_preview_open_browser()
EOF
endfunction


function! MarkdownPreview#Do()
python << EOF
markdown_preview_generate()
EOF
endfunction


function! MarkdownPreview#DoIfNeeded()
python << EOF
freq_ms = float(vim.vars['markdown_preview_frequency_ms'])
markdown_preview_generate_after(freq_ms*0.001)
EOF
endfunction


function! MarkdownPreview#OpenBrowser()
python << EOF
markdown_preview_open_browser()
EOF
endfunction


function! MarkdownPreview#OpenBrowserIfNeeded()
    if !exists('b:markdown_preview_opened') || !b:markdown_preview_opened
        call MarkdownPreview#OpenBrowser()
    endif
endfunction


call MarkdownPreview#Init()

let g:loaded_markdown_preview = 1
