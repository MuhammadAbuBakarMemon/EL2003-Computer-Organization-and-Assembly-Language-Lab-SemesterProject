searchPrompt      DB 0Dh,0Ah,"Enter Name to Search: ",0
searchFoundMsg    DB 0Dh,0Ah,"--- Contact Found ---",0Dh,0Ah,0
searchNotFoundMsg DB 0Dh,0Ah,"-- Contact not found in directory. --",0Dh,0Ah,0
autoSearchMsg     DB 0Dh,0Ah,"[Mode: Linear Auto Search]",0Dh,0Ah,0

lowIdx            SDWORD ?
highIdx           SDWORD ?
midIdx            SDWORD ?

SearchContact PROC
call Clrscr

cmp  Contact_Count, 0
je   sc_not_found

mov  edx, OFFSET searchPrompt
call WriteString

mov  edx, OFFSET tempBuf
mov  ecx, Name_Size - 1
call ReadString
mov  byte ptr [tempBuf + eax], 0

cmp  eax, 0
je   sc_exit

mov  lowIdx, 0

mov  eax, Contact_Count
dec  eax
mov  highIdx, eax

sc_loop:
mov  eax, lowIdx
cmp  eax, highIdx
jg   sc_not_found

mov  eax, lowIdx
add  eax, highIdx
sar  eax, 1
mov  midIdx, eax

mov  eax, midIdx
imul eax, Name_Size
lea  edi, names[eax]
mov  esi, OFFSET tempBuf

INVOKE Str_compare, esi, edi

je   sc_found
jb   sc_go_left
ja   sc_go_right

sc_go_left:
mov  eax, midIdx
dec  eax
mov  highIdx, eax
jmp  sc_loop

sc_go_right:
mov  eax, midIdx
inc  eax
mov  lowIdx, eax
jmp  sc_loop

sc_found:
mov  edx, OFFSET searchFoundMsg
call WriteString
mov  ebx, midIdx
call DisplaySingleContact
jmp  sc_exit

sc_not_found:
mov  edx, OFFSET searchNotFoundMsg
call WriteString

sc_exit:
ret
SearchContact ENDP

AutoSearch PROC
call Clrscr

cmp  Contact_Count, 0
je   as_not_found

mov  edx, OFFSET autoSearchMsg
call WriteString

mov  edx, OFFSET searchPrompt
call WriteString

mov  edx, OFFSET tempBuf
mov  ecx, Name_Size - 1
call ReadString
mov  byte ptr [tempBuf + eax], 0

cmp  eax, 0
je   as_exit

mov  ecx, Contact_Count
mov  ebx, 0

as_loop:
mov  eax, ebx
imul eax, Name_Size
lea  edi, names[eax]
mov  esi, OFFSET tempBuf

push ecx
INVOKE Str_compare, esi, edi
pop  ecx

je   as_found

inc  ebx
loop as_loop

jmp  as_not_found

as_found:
mov  edx, OFFSET searchFoundMsg
call WriteString

call DisplaySingleContact
jmp  as_exit

as_not_found:
mov  edx, OFFSET searchNotFoundMsg
call WriteString

as_exit:
ret
AutoSearch ENDP

DisplaySingleContact PROC
mov  edx, OFFSET NamePrompt
call WriteString

mov  eax, ebx
imul eax, Name_Size
lea  edx, names[eax]
call WriteString
call Crlf

mov  edx, OFFSET PhPrompt
call WriteString

mov  eax, ebx
imul eax, Ph_Num_Size
lea  edx, nums[eax]
call WriteString
call Crlf

mov  edx, OFFSET AddrPrompt
call WriteString

mov  eax, ebx
imul eax, Addr_Size
lea  edx, addrs[eax]
call WriteString
call Crlf

mov  edx, OFFSET EmailPrompt
call WriteString

mov  eax, ebx
imul eax, Email_Size
lea  edx, emails[eax]
call WriteString
call Crlf
ret
DisplaySingleContact ENDP
