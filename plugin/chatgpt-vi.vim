if !exists("g:openai_token")
  let g:openai_token = system("cat ~/.config/openai.token | tr '\n' ' '")
endif


function! ChatGPT()

  let bufnum = bufnr(".chatgpt")
  if !bufexists(bufnum)
    let bufnum = bufadd(".chatgpt")
  endif

  call setbufvar(bufnum, "&buftype", "nofile")
  " delete everything
  call deletebufline(bufnum, 1, '$')
  " set answer here
  call setbufline(bufnum, 1, split(AskGPT(), '\n'))
  
  if bufwinnr(bufnum) == -1
    vsplit
    let l:winnum = win_getid()
    call setwinvar(winnum, "&winwidth", 20)
    execute 'buffer' bufnum
  endif

endfunction


function! CreateJSON()
  let l:message = input("Enter question ", "")
  let l:json = '{
          \ "model": "gpt-3.5-turbo", 
          \ "messages": [{"role": "user", "content": "' . message . '" }]
          \ }'
  return json
endfunction


function! AskGPT()
  let l:content = CreateJSON()
  let l:auth_text = '"Authorization: Bearer ' . g:openai_token . '"'
  if executable('curl')
    let l:curl_text = 'curl -s "https://api.openai.com/v1/chat/completions" ' . 
          \ '-H "Content-Type: application/json" ' .
          \ '-H ' . auth_text . ' ' . 
          \ '-d ' . shellescape(content) 
    let l:res = json_decode(system(curl_text))
    return res["choices"][0]["message"]["content"]
  endif
endfunction

command! AskGPT call ChatGPT()

nnoremap ask :AskGPT<cr>
