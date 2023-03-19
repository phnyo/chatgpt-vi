if !exists("g:openai_token")
  let g:openai_token = system("cat ~/.config/openai.token | tr '\n' ' '")
endif

let s:message_list = []

function! s:procGPT(job_id, data, event) 
  
  let bufnum = bufnr(".chatgpt")
  if !bufexists(bufnum)
    let bufnum = bufadd(".chatgpt")
  else
    " delete everything
    call deletebufline(bufnum, 1, '$')
  endif

  call setbufvar(bufnum, "&buftype", "nofile")
  
  if bufwinnr(bufnum) == -1
    vsplit
    execute 'buffer' bufnum
  endif

  if a:event == 'stdout'
    echo '.'
    call add(s:message_list, a:data)
  else
    let l:res = json_decode(s:message_list[0])
    let l:message = res["choices"][0]["message"]["content"]
    call setbufline(bufnum, 1, split(l:message, '\n'))
    echo 'answered!'
  endif

endfunction


function! s:createJSON()
  let l:message = input("Enter question ", "")
  let l:json = '{
          \ "model": "gpt-3.5-turbo-0301", 
          \ "messages": [{"role": "user", "content": " 
          \ you are an experienced and charismatic programmer working at google willing to help junior programmer.
          \ answer below question in detail about the technology in use so that the junior programmer 
          \ can easy understand and start their own job.
          \ ' . message . '" }]
          \ }'
  return json
endfunction


function! AskGPT()
  let l:content = s:createJSON()
  let l:auth_text = '"Authorization: Bearer ' . g:openai_token . '"'

  if executable('curl')
    let l:curl_text = 'curl -s "https://api.openai.com/v1/chat/completions" ' . 
          \ '-H "Content-Type: application/json" ' .
          \ '-H ' . auth_text . ' ' . 
          \ '-d ' . shellescape(content) 
    echo ' asking chatGPT...'
    let l:job = jobstart(curl_text, { 
          \ 'on_stdout': function("s:procGPT"),
          \ 'on_exit': function("s:procGPT")})
  endif
endfunction

command! AskGPT call AskGPT()

nnoremap ask AskGPT
