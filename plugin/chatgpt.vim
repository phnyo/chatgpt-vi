if exists("g:loaded_chatgpt_vi_plugin")
  finish
endif

g:loaded_chatgpt_vi_plugin = 1

command! Ask call chatgpt-vi#ChatGPT()
