INCLUDE Irvine32.inc

.data

    ; Constants
    Max_Contacts      =  20
    Name_Size         =  30
    Ph_Num_Size       =  15
    Addr_Size         =  50
    Email_Size        =  30

    ; storage (arrays of fixed-size records)
    names             DB Max_Contacts * Name_Size DUP(?)
    nums              DB Max_Contacts * Ph_Num_Size DUP(?)
    addrs             DB Max_Contacts * Addr_Size DUP(?)
    emails            DB Max_Contacts * Email_Size DUP(?)
    Contact_Count     DD 0

    ; prompts / messages
    MenuHeader        DB " ----- Main Menu ----- ",0Dh,0Ah,0
    MenuList          DB 0Dh,0Ah,"1. Add",0Dh,0Ah,"2. Update (Sort)",0Dh,0Ah,"3. Display",0Dh,0Ah,"4. Delete",0Dh,0Ah,"5. Search",0Dh,0Ah,"6. Exit Directory",0Dh,0Ah,0
    MenuChoiceMsg     DB 0Dh,0Ah,"Enter your Choice: ",0
    InvalidMenuChoice DB 0Dh,0Ah,"Invalid Choice!",0Dh,0Ah,0

    NamePrompt        DB "Name: ",0
    PhPrompt          DB "Phone Number: ",0
    AddrPrompt        DB "Address: ",0
    EmailPrompt       DB "Email: ",0

    addMsg            DB "Enter Following Details: ",0
    addedMsg          DB 0Dh,0Ah,"-- Contact has been added to the directory. --",0Dh,0Ah,0
    dirFullMsg        DB 0Dh,0Ah,"Contact Directory is Full! No more contacts can be added.",0Dh,0Ah,0
    continueMsg       DB 0Dh,0Ah,"Press any key to continue...",0

    doneSortMsg       DB 0Dh,0Ah,"-- Contacts sorted successfully. --",0Dh,0Ah,0
    
    displayEmptyMsg   DB 0Dh,0Ah,"-- Contact Directory is empty. --",0Dh,0Ah,0
    contactHeader     DB 0Dh,0Ah,"Contact #: ",0
    contactDiv        DB 0Dh,0Ah,"------------------------------",0Dh,0Ah,0

    ; Update/Edit UI strings
    UpdatePrompt      DB 0Dh,0Ah,"Enter contact number to update: ",0
    UpdateMenuList    DB 0Dh,0Ah,"Update Options:",0Dh,0Ah,"1. Name",0Dh,0Ah,"2. Phone",0Dh,0Ah,"3. Address",0Dh,0Ah,"4. Email",0Dh,0Ah,"5. All Fields",0Dh,0Ah,"6. Cancel",0Dh,0Ah,0
    UpdateChoiceMsg   DB 0Dh,0Ah,"Choose field to update: ",0
    updatedMsg        DB 0Dh,0Ah,"-- Contact updated. --",0Dh,0Ah,0
    updateCancelMsg   DB 0Dh,0Ah,"-- Update canceled. --",0Dh,0Ah,0
    invalidIndexMsg   DB 0Dh,0Ah,"Invalid contact number!",0Dh,0Ah,0

    ; temporary buffer for safe editing (largest field size)
    tempBuf           DB Addr_Size DUP(?)

.code

                    _Wait  PROTO

main PROC
    top:            
                    mov    edx, OFFSET MenuHeader
                    call   WriteString
                    mov    edx, OFFSET MenuList
                    call   WriteString
                    mov    edx, OFFSET MenuChoiceMsg
                    call   WriteString
                    call   ReadInt                          ; returns choice in EAX

                    cmp    eax, 1
                    je     _add
                    cmp    eax, 2
                    je     _update
                    cmp    eax, 3
                    je     _display
                    cmp    eax, 4
                    je     _delete
                    cmp    eax, 5
                    je     _search
                    cmp    eax, 6
                    je     _exit

                    mov    edx, OFFSET InvalidMenuChoice
                    call   WriteString
                    jmp    _refresh

    _add:           
                    call   AddContact
                    jmp    _refresh

    _update:        
    ; TODO: Implement a UpdateContact procedure
                    jmp    _refresh

    _display:       
    ; TODO: Implement a DisplayContacts procedure
                    call   writeDec
                    jmp    _refresh

    _delete:        
    ; TODO: Implement a DeleteContact procedure
                    call   writeDec
                    jmp    _refresh

    _search:        
    ; TODO: Implement a SearchContact procedure
                    call   writeDec
                    jmp    _refresh

    _refresh:       
                    call   _Wait
                    call   Clrscr
                    jmp    top

    _exit:          
                    Exit
main ENDP

_Wait PROC
                    mov    edx, OFFSET continueMsg
                    call   WriteString
                    call   ReadChar
                    ret
_Wait ENDP

    ; ----------------------
    ; AddContact - add next free contact
    ; ----------------------
AddContact PROC
    ; compare Contact_Count and Max_Contacts
                    mov    eax, Contact_Count
                    cmp    eax, Max_Contacts
                    jae    dirFull

                    mov    edx, OFFSET addMsg
                    call   WriteString
                    call   Crlf

                    mov    ecx, Contact_Count               ; ECX = current index i

    ; Name
                    mov    ebx, ecx
                    imul   ebx, Name_Size
                    lea    edi, names[ebx]
                    mov    edx, OFFSET NamePrompt
                    call   WriteString
                    mov    edx, edi
                    mov    eax, Name_Size - 1               ; Max chars to read (one less for null-terminator)
                    push   eax
                    mov    ecx, eax
                    call   ReadString                       ; Returns actual length in EAX
                    pop    ecx
                    mov    byte ptr [edi + eax], 0          ; Null-terminate the string

    ; Phone
                    mov    ebx, ecx                         ; EBX = i
                    imul   ebx, Ph_Num_Size
                    lea    edi, nums[ebx]
                    mov    edx, OFFSET PhPrompt
                    call   WriteString
                    mov    edx, edi
                    mov    eax, Ph_Num_Size - 1
                    push   eax
                    mov    ecx, eax
                    call   ReadString
                    pop    ecx
                    mov    byte ptr [edi + eax], 0

    ; Address
                    mov    ebx, ecx                         ; EBX = i
                    imul   ebx, Addr_Size
                    lea    edi, addrs[ebx]
                    mov    edx, OFFSET AddrPrompt
                    call   WriteString
                    mov    edx, edi
                    mov    eax, Addr_Size - 1
                    push   eax
                    mov    ecx, eax
                    call   ReadString
                    pop    ecx
                    mov    byte ptr [edi + eax], 0

    ; Email
                    mov    ebx, ecx                         ; EBX = i
                    imul   ebx, Email_Size
                    lea    edi, emails[ebx]
                    mov    edx, OFFSET EmailPrompt
                    call   WriteString
                    mov    edx, edi
                    mov    eax, Email_Size - 1
                    push   eax
                    mov    ecx, eax
                    call   ReadString
                    pop    ecx
                    mov    byte ptr [edi + eax], 0

    ; increment count (DWORD)
                    mov    eax, Contact_Count
                    inc    eax
                    mov    Contact_Count, eax

                    mov    edx, OFFSET addedMsg
                    call   WriteString
                    ret

    dirFull:        
                    mov    edx, OFFSET dirFullMsg
                    call   WriteString
                    ret
AddContact ENDP

    ; ----------------------
    ; swapblock - swap ECX bytes between [ESI] and [EDI]
    ; ----------------------
swapblock PROC
                    push   esi
                    push   edi
                    push   ecx
    ; ESI and EDI point to blocks; ECX = byte count
    swap_loop:      
                    mov    al, [esi]
                    mov    bl, [edi]
                    mov    [esi], bl
                    mov    [edi], al
                    inc    esi
                    inc    edi
                    dec    ecx
                    jnz    swap_loop
                    pop    ecx
                    pop    edi
                    pop    esi
                    ret
swapblock ENDP

    ; ----------------------
    ; SortContact - bubble sort by name ascending
    ; ----------------------
SortContact PROC
                    pushad

                    mov    eax, Contact_Count
                    cmp    eax, 2
                    jb     doneSorting                      ; 0 or 1 contact - nothing to sort

                    dec    eax
                    mov    ecx, eax                         ; ECX = N-1 (outer passes count down to 1)

    outer_loop:     
                    push   ecx                              ; Save outer loop counter
                    mov    ebx, 0                           ; EBX = i index (0)
                    mov    edx, ecx                         ; EDX = Inner loop limit for i (i < EDX)

    inner_loop:     
                    cmp    ebx, edx                         ; Compare i (EBX) with limit (EDX)
                    jae    inner_done_pass                  ; if i >= limit, done with inner loop for this pass

    ; compute pointers for names[i] and names[i+1]
                    mov    esi, ebx
                    imul   esi, Name_Size
                    lea    esi, names[esi]

                    mov    edi, ebx
                    inc    edi
                    imul   edi, Name_Size
                    lea    edi, names[edi]

    ; compare names lexicographically
                    mov    eax, Name_Size                   ; Using EAX as temp loop counter for comparison
    compare_loop:   
                    mov    cl, [esi]                        ; Use CL for current char [i]
                    mov    dl, [edi]                        ; Use DL for current char [i+1]
                    cmp    cl, dl
                    jne    compare_diff                     ; Different, check if swap needed
                    cmp    cl, 0
                    je     compare_equal                    ; Reached null-terminator (strings are equal)
                    inc    esi
                    inc    edi
                    dec    eax
                    jnz    compare_loop
                    jmp    compare_equal                    ; Strings are equal up to Name_Size

    compare_diff:   
                    cmp    cl, dl
                    ja     do_swap                          ; cl > dl means names[i] > names[i+1], so swap (ascending sort)
                    jmp    no_swap                          ; cl < dl means already in order

    compare_equal:  
                    jmp    no_swap                          ; Strings are considered equal (no swap needed)

    do_swap:        
    ; swap Name (i is in EBX)
                    mov    eax, ebx
                    imul   eax, Name_Size
                    lea    esi, names[eax]
                    mov    edi, ebx
                    inc    edi
                    imul   edi, Name_Size
                    lea    edi, names[edi]
                    mov    ecx, Name_Size
                    call   swapblock

    ; swap Phone
                    mov    eax, ebx
                    imul   eax, Ph_Num_Size
                    lea    esi, nums[eax]
                    mov    edi, ebx
                    inc    edi
                    imul   edi, Ph_Num_Size
                    lea    edi, nums[edi]
                    mov    ecx, Ph_Num_Size
                    call   swapblock

    ; swap Address
                    mov    eax, ebx
                    imul   eax, Addr_Size
                    lea    esi, addrs[eax]
                    mov    edi, ebx
                    inc    edi
                    imul   edi, Addr_Size
                    lea    edi, addrs[edi]
                    mov    ecx, Addr_Size
                    call   swapblock

    ; swap Email
                    mov    eax, ebx
                    imul   eax, Email_Size
                    lea    esi, emails[eax]
                    mov    edi, ebx
                    inc    edi
                    imul   edi, Email_Size
                    lea    edi, emails[edi]
                    mov    ecx, Email_Size
                    call   swapblock

    no_swap:        
                    inc    ebx
                    jmp    inner_loop

    inner_done_pass:
                    pop    ecx                              ; Restore outer loop counter
                    dec    ecx                              ; Decrement outer loop counter
                    jnz    outer_loop                       ; Jump if not zero (more passes to go)

    doneSorting:    
                    mov    edx, OFFSET doneSortMsg
                    call   WriteString
                    popad
                    ret
SortContact ENDP

END main
