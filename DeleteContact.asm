delPrompt       DB 0Dh,0Ah,"Enter Contact # to delete: ",0
delConfirmMsg   DB 0Dh,0Ah,"-- Contact deleted successfully. --",0Dh,0Ah,0
delErrEmpty     DB 0Dh,0Ah,"Error: Directory is empty.",0Dh,0Ah,0
delErrInvalid   DB 0Dh,0Ah,"Error: Invalid Contact Number.",0Dh,0Ah,0

DeleteContact PROC
    pushad

    mov  eax, Contact_Count
    cmp  eax, 0
    je   del_empty

    mov  edx, OFFSET delPrompt
    call WriteString
    call ReadInt

    cmp  eax, 1
    jl   del_invalid
    cmp  eax, Contact_Count
    jg   del_invalid

    dec  eax
    mov  ebx, eax
    
    mov  ecx, Contact_Count
    dec  ecx
    sub  ecx, ebx
    
    cmp  ecx, 0
    je   del_decrement_only

    push ecx

    mov  eax, ebx
    imul eax, Name_Size
    lea  edi, names[eax]
    
    mov  esi, edi
    add  esi, Name_Size

    mov  eax, [esp]
    imul eax, Name_Size
    mov  ecx, eax
    
    cld
    rep  movsb

    mov  eax, ebx
    imul eax, Ph_Num_Size
    lea  edi, nums[eax]
    mov  esi, edi
    add  esi, Ph_Num_Size
    
    mov  eax, [esp]
    imul eax, Ph_Num_Size
    mov  ecx, eax
    rep  movsb

    mov  eax, ebx
    imul eax, Addr_Size
    lea  edi, addrs[eax]
    mov  esi, edi
    add  esi, Addr_Size
    
    mov  eax, [esp]
    imul eax, Addr_Size
    mov  ecx, eax
    rep  movsb

    mov  eax, ebx
    imul eax, Email_Size
    lea  edi, emails[eax]
    mov  esi, edi
    add  esi, Email_Size
    
    mov  eax, [esp]
    imul eax, Email_Size
    mov  ecx, eax
    rep  movsb

    pop  ecx

del_decrement_only:
    dec  Contact_Count
    
    mov  edx, OFFSET delConfirmMsg
    call WriteString
    jmp  del_exit

del_empty:
    mov  edx, OFFSET delErrEmpty
    call WriteString
    jmp  del_exit

del_invalid:
    mov  edx, OFFSET delErrInvalid
    call WriteString
    jmp  del_exit

del_exit:
    popad
    ret
DeleteContact ENDP
