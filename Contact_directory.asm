INCLUDE c:\Users\Dell\.vscode\extensions\istareatscreens.masm-runner-0.9.1\native\irvine\Irvine32.inc

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

    ; temporary buffer for safe editing (largest field size)
    tempBuf           DB Addr_Size DUP(?)

    validationBuf     DB 100 DUP(?)

    ; prompts / messages
    MenuHeader        DB " ----- Main Menu ----- ",0Dh,0Ah,0
    MenuList          DB 0Dh,0Ah,"1. Add",0Dh,0Ah,"2. Update ",0Dh,0Ah,"3. Display",0Dh,0Ah,"4. Delete",0Dh,0Ah,"5. Search",0Dh,0Ah,"6. Exit Directory",0Dh,0Ah,0
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

    emptyInputMsg     DB 0Dh,0Ah,"Error: Input cannot be empty!",0Dh,0Ah,0
    invalidPhone      DB 0Dh,0Ah,"Error: Phone must contain only digits, +, -!",0Dh,0Ah,0
    invalidEmail      DB 0Dh,0Ah,"Error: Invalid Email Format", 0Dh,0Ah,0
    retryPrompt       DB 0Dh,0Ah,"Press Enter to retry or 'C' to Cancel: ",0

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
                          call   UpdateContacts
                          jmp    _refresh

    _display:             
                          call   DisplayContacts
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
                          mov    eax, Contact_Count
                          cmp    eax, Max_Contacts
                          jae    dirFull

                          mov    edx, OFFSET addMsg
                          call   WriteString
                          call   Crlf

                          mov    esi, Contact_Count               ; ESI = current index

    ; --- Validated Name Input ---
                          mov    ebx, esi
                          imul   ebx, Name_Size
                          lea    edi, names[ebx]
    
                          mov    edx, OFFSET NamePrompt
                          call   WriteString
    
                          mov    edx, edi                         ; Destination buffer
                          mov    ecx, Name_Size - 1               ; Max length
                          mov    esi, OFFSET ValidateName         ; Validation proc
                          mov    edi, OFFSET invalidNameMsg       ; Error message
                          call   ReadValidatedString
                          jc     add_cancelled                    ; User cancelled
    
    ; --- Validated Phone Input ---
                          mov    esi, Contact_Count               ; Restore index
                          mov    ebx, esi
                          imul   ebx, Ph_Num_Size
                          lea    edi, nums[ebx]
    
                          mov    edx, OFFSET PhPrompt
                          call   WriteString
    
                          mov    edx, edi
                          mov    ecx, Ph_Num_Size - 1
                          mov    esi, OFFSET ValidatePhone
                          mov    edi, OFFSET invalidPhoneMsg
                          call   ReadValidatedString
                          jc     add_cancelled
    
    ; --- Address (no special validation) ---
                          mov    esi, Contact_Count
                          mov    ebx, esi
                          imul   ebx, Addr_Size
                          lea    edi, addrs[ebx]
    
                          mov    edx, OFFSET AddrPrompt
                          call   WriteString
    
                          mov    edx, edi
                          mov    ecx, Addr_Size - 1
                          xor    esi, esi                      
                          xor    edi, edi
                          call   ReadValidatedString
                          jc     add_cancelled
    
    ; --- Validated Email Input ---
                          mov    esi, Contact_Count
                          mov    ebx, esi
                          imul   ebx, Email_Size
                          lea    edi, emails[ebx]
    
                          mov    edx, OFFSET EmailPrompt
                          call   WriteString
    
                          mov    edx, edi
                          mov    ecx, Email_Size - 1
                          mov    esi, OFFSET ValidateEmail
                          mov    edi, OFFSET invalidEmailMsg
                          call   ReadValidatedString
                          jc     add_cancelled

    ; Success - increment count
                          inc    Contact_Count
                          mov    edx, OFFSET addedMsg
                          call   WriteString
                          ret

    add_cancelled:        
                          mov    edx, OFFSET updateCancelMsg
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

    ; ----------------------
    ; UpdateContact - update existing contact(s)
    ; ----------------------
UpdateContacts PROC
                          pushad
                          mov    eax, Contact_Count
                          cmp    eax, 0
                          je     uc_display_empty

    ; Show all contacts to help user choose
                          call   DisplayContacts

    ; Prompt for contact number to edit (1-based)
                          mov    edx, OFFSET UpdatePrompt
                          call   WriteString
                          call   ReadInt                          ; returns number in EAX
                          mov    ebx, eax                         ; ebx = user_choice (1-based)
                          cmp    ebx, 1
                          jl     uc_invalid_index
                          mov    eax, Contact_Count
                          cmp    ebx, eax
                          jg     uc_invalid_index

    ; convert to 0-based index
                          dec    ebx                              ; EBX = index (0-based)

    ; Display current fields for this contact
    ; Name
                          mov    esi, ebx
                          imul   esi, Name_Size
                          mov    edx, OFFSET NamePrompt
                          call   WriteString
                          lea    edx, names[esi]
                          call   WriteString
                          call   Crlf

    ; Phone
                          mov    esi, ebx
                          imul   esi, Ph_Num_Size
                          mov    edx, OFFSET PhPrompt
                          call   WriteString
                          lea    edx, nums[esi]
                          call   WriteString
                          call   Crlf

    ; Address
                          mov    esi, ebx
                          imul   esi, Addr_Size
                          mov    edx, OFFSET AddrPrompt
                          call   WriteString
                          lea    edx, addrs[esi]
                          call   WriteString
                          call   Crlf

    ; Email
                          mov    esi, ebx
                          imul   esi, Email_Size
                          mov    edx, OFFSET EmailPrompt
                          call   WriteString
                          lea    edx, emails[esi]
                          call   WriteString
                          call   Crlf

    ; Show update menu
                          mov    edx, OFFSET UpdateMenuList
                          call   WriteString
                          mov    edx, OFFSET UpdateChoiceMsg
                          call   WriteString
                          call   ReadInt                          ; choice in EAX
                          mov    ecx, eax                         ; ECX = which field to update

                          cmp    ecx, 6
                          je     uc_cancel

                          cmp    ecx, 1
                          je     uc_update_name
                          cmp    ecx, 2
                          je     uc_update_phone
                          cmp    ecx, 3
                          je     uc_update_addr
                          cmp    ecx, 4
                          je     uc_update_email
                          cmp    ecx, 5
                          je     uc_update_all

    ; invalid choice
                          mov    edx, OFFSET InvalidMenuChoice
                          call   WriteString
                          jmp    uc_done

    ; ----------------------
    ; update name (safe: read into tempBuf first; if input length > 0, copy to target)
    ; ----------------------
    uc_update_name:       
    ; prompt
                          mov    edx, OFFSET NamePrompt
                          call   WriteString

    ; read into tempBuf
                          lea    edi, tempBuf
                          mov    edx, edi
                          mov    eax, Name_Size - 1
                          push   eax
                          mov    ecx, eax
                          call   ReadString
                          pop    ecx
                          mov    byte ptr [edi + eax], 0          ; null-terminate temp
                          cmp    eax, 0
                          je     uc_name_nochange

    ; copy tempBuf -> names[ebx * Name_Size]
                          cld
                          mov    esi, OFFSET tempBuf
                          mov    edi, ebx
                          imul   edi, Name_Size
                          lea    edi, names[edi]
                          mov    ecx, eax
                          rep    movsb
                          mov    byte ptr [edi + ecx], 0
                          jmp    uc_updated

    uc_name_nochange:     
                          mov    edx, OFFSET updateCancelMsg
                          call   WriteString
                          jmp    uc_done

    ; ----------------------
    ; update phone
    ; ----------------------
    uc_update_phone:      
                          mov    edx, OFFSET PhPrompt
                          call   WriteString

                          lea    edi, tempBuf
                          mov    edx, edi
                          mov    eax, Ph_Num_Size - 1
                          push   eax
                          mov    ecx, eax
                          call   ReadString
                          pop    ecx
                          mov    byte ptr [edi + eax], 0
                          cmp    eax, 0
                          je     uc_phone_nochange

    ; copy tempBuf -> nums[ebx * Ph_Num_Size]
                          cld
                          mov    esi, OFFSET tempBuf
                          mov    edi, ebx
                          imul   edi, Ph_Num_Size
                          lea    edi, nums[edi]
                          mov    ecx, eax
                          rep    movsb
                          mov    byte ptr [edi + ecx], 0
                          jmp    uc_updated

    uc_phone_nochange:    
                          mov    edx, OFFSET updateCancelMsg
                          call   WriteString
                          jmp    uc_done

    ; ----------------------
    ; update address
    ; ----------------------
    uc_update_addr:       
                          mov    edx, OFFSET AddrPrompt
                          call   WriteString

                          lea    edi, tempBuf
                          mov    edx, edi
                          mov    eax, Addr_Size - 1
                          push   eax
                          mov    ecx, eax
                          call   ReadString
                          pop    ecx
                          mov    byte ptr [edi + eax], 0
                          cmp    eax, 0
                          je     uc_addr_nochange

    ; copy tempBuf -> addrs[ebx * Addr_Size]
                          cld
                          mov    esi, OFFSET tempBuf
                          mov    edi, ebx
                          imul   edi, Addr_Size
                          lea    edi, addrs[edi]
                          mov    ecx, eax
                          rep    movsb
                          mov    byte ptr [edi + ecx], 0
                          jmp    uc_updated

    uc_addr_nochange:     
                          mov    edx, OFFSET updateCancelMsg
                          call   WriteString
                          jmp    uc_done

    ; ----------------------
    ; update email
    ; ----------------------
    uc_update_email:      
                          mov    edx, OFFSET EmailPrompt
                          call   WriteString

                          lea    edi, tempBuf
                          mov    edx, edi
                          mov    eax, Email_Size - 1
                          push   eax
                          mov    ecx, eax
                          call   ReadString
                          pop    ecx
                          mov    byte ptr [edi + eax], 0
                          cmp    eax, 0
                          je     uc_email_nochange

    ; copy tempBuf -> emails[ebx * Email_Size]
                          cld
                          mov    esi, OFFSET tempBuf
                          mov    edi, ebx
                          imul   edi, Email_Size
                          lea    edi, emails[edi]
                          mov    ecx, eax
                          rep    movsb
                          mov    byte ptr [edi + ecx], 0
                          jmp    uc_updated

    uc_email_nochange:    
                          mov    edx, OFFSET updateCancelMsg
                          call   WriteString
                          jmp    uc_done

    ; ----------------------
    ; update all fields (asks for each; empty input will keep the existing field)
    ; ----------------------
    uc_update_all:        
    ; Name
                          mov    edx, OFFSET NamePrompt
                          call   WriteString
                          lea    edi, tempBuf
                          mov    edx, edi
                          mov    eax, Name_Size - 1
                          push   eax
                          mov    ecx, eax
                          call   ReadString
                          pop    ecx
                          mov    byte ptr [edi + eax], 0
                          cmp    eax, 0
                          je     uc_skip_name_copy
                          cld
                          mov    esi, OFFSET tempBuf
                          mov    edi, ebx
                          imul   edi, Name_Size
                          lea    edi, names[edi]
                          mov    ecx, eax
                          rep    movsb
                          mov    byte ptr [edi + ecx], 0
    uc_skip_name_copy:    

    ; Phone
                          mov    edx, OFFSET PhPrompt
                          call   WriteString
                          lea    edi, tempBuf
                          mov    edx, edi
                          mov    eax, Ph_Num_Size - 1
                          push   eax
                          mov    ecx, eax
                          call   ReadString
                          pop    ecx
                          mov    byte ptr [edi + eax], 0
                          cmp    eax, 0
                          je     uc_skip_phone_copy
                          cld
                          mov    esi, OFFSET tempBuf
                          mov    edi, ebx
                          imul   edi, Ph_Num_Size
                          lea    edi, nums[edi]
                          mov    ecx, eax
                          rep    movsb
                          mov    byte ptr [edi + ecx], 0
    uc_skip_phone_copy:   

    ; Address
                          mov    edx, OFFSET AddrPrompt
                          call   WriteString
                          lea    edi, tempBuf
                          mov    edx, edi
                          mov    eax, Addr_Size - 1
                          push   eax
                          mov    ecx, eax
                          call   ReadString
                          pop    ecx
                          mov    byte ptr [edi + eax], 0
                          cmp    eax, 0
                          je     uc_skip_addr_copy
                          cld
                          mov    esi, OFFSET tempBuf
                          mov    edi, ebx
                          imul   edi, Addr_Size
                          lea    edi, addrs[edi]
                          mov    ecx, eax
                          rep    movsb
                          mov    byte ptr [edi + ecx], 0
    uc_skip_addr_copy:    

    ; Email
                          mov    edx, OFFSET EmailPrompt
                          call   WriteString
                          lea    edi, tempBuf
                          mov    edx, edi
                          mov    eax, Email_Size - 1
                          push   eax
                          mov    ecx, eax
                          call   ReadString
                          pop    ecx
                          mov    byte ptr [edi + eax], 0
                          cmp    eax, 0
                          je     uc_skip_email_copy
                          cld
                          mov    esi, OFFSET tempBuf
                          mov    edi, ebx
                          imul   edi, Email_Size
                          lea    edi, emails[edi]
                          mov    ecx, eax
                          rep    movsb
                          mov    byte ptr [edi + ecx], 0
    uc_skip_email_copy:   
                          jmp    uc_updated

    uc_updated:           
                          mov    edx, OFFSET updatedMsg
                          call   WriteString
                          jmp    uc_done

    uc_cancel:            
                          mov    edx, OFFSET updateCancelMsg
                          call   WriteString
                          jmp    uc_done

    uc_invalid_index:     
                          mov    edx, OFFSET invalidIndexMsg
                          call   WriteString
                          jmp    uc_done

    uc_display_empty:     
                          mov    edx, OFFSET displayEmptyMsg
                          call   WriteString
                          jmp    uc_end

    uc_done:              
    ; fall through to restore and return
                          nop

    uc_end:               
                          popad
                          ret
UpdateContacts ENDP

    ; ----------------------
    ; DisplayContacts - list all contacts
    ; ----------------------
DisplayContacts PROC
                          pushad

                          mov    eax, Contact_Count
                          cmp    eax, 0
                          je     display_empty

                          mov    ebx, 0                           ; index = 0
    display_loop:         
    ; Print divider
                          mov    edx, OFFSET contactDiv
                          call   WriteString

    ; Print contact number
                          mov    edx, OFFSET contactHeader
                          call   WriteString
                          mov    eax, ebx
                          inc    eax                              ; display 1-based index
                          call   WriteInt                         ; WriteInt prints EAX
                          call   Crlf

    ; Print Name
                          mov    esi, ebx
                          imul   esi, Name_Size
                          mov    edx, OFFSET NamePrompt
                          call   WriteString                      ; "Name: "
                          lea    edx, names[esi]
                          call   WriteString
                          call   Crlf

    ; Print Phone
                          mov    esi, ebx
                          imul   esi, Ph_Num_Size
                          mov    edx, OFFSET PhPrompt
                          call   WriteString
                          lea    edx, nums[esi]
                          call   WriteString
                          call   Crlf

    ; Print Address
                          mov    esi, ebx
                          imul   esi, Addr_Size
                          mov    edx, OFFSET AddrPrompt
                          call   WriteString
                          lea    edx, addrs[esi]
                          call   WriteString
                          call   Crlf

    ; Print Email
                          mov    esi, ebx
                          imul   esi, Email_Size
                          mov    edx, OFFSET EmailPrompt
                          call   WriteString
                          lea    edx, emails[esi]
                          call   WriteString
                          call   Crlf

                          inc    ebx
                          mov    eax, Contact_Count
                          cmp    ebx, eax
                          jl     display_loop

    ; final divider
                          mov    edx, OFFSET contactDiv
                          call   WriteString

                          popad
                          ret

    display_empty:        
                          mov    edx, OFFSET displayEmptyMsg
                          call   WriteString
                          popad
                          ret
DisplayContacts ENDP

ValidateNotEmpty PROC
                          push   esi
                          mov    esi, edi

    skipSpaces:           
                          mov    al, [esi]
                          cmp    al, ' '
                          jne    checkEmpty
                          inc    esi
                          jmp    skipSpaces

    checkEmpty:           
                          cmp    al, 0
                          je     isEmpty
    
                          mov    eax, 1
                          pop    esi
                          ret

    isEmpty:              
                          mov    eax, 0
                          pop    esi
                          ret
    
ValidateNotEmpty ENDP

ValidateName Proc
                          push   esi
                          mov    esi, edi

    nameLoop:             
                          mov    al, [esi]
                          cmp    , 0
                          je     _valid

                          cmp    al, ' '
                          je     _next

                          cmp    al, 'A'
                          jl     _invalid

                          cmp    al, 'Z'
                          jle    _next

                          cmp    al, 'a'
                          jl     _invalid

                          cmp    al, 'z'
                          jle    _next

                          jmp    _invalid

    _next:                
                          inc    esi
                          jmp    nameLoop

    _valid:               
                          mov    eax, 1
                          pop    esi
                          ret
    
    _invalid:             
                          mov    eax, 0
                          pop    esi
                          ret
ValidateName ENDP

ValidatePhone PROC
                          push   esi
                          push   ebx
                          mov    esi, edi
                          xor    ebx, ebx

    phoneLoop:            
                          mov    al, [esi]
                          cmp    al, 0
                          je     checkPhoneCount

                          cmp    al, '0'
                          jl     checkSpChar

                          cmp    al, '9'
                          jle    digFound

    checkSpChar:          
                          cmp    al, ' '
                          je     _next
                          cmp    al, '+'
                          je     _next
                          cmp    al, '-'
                          je     _next

                          jmp    _invalid

    digFound:             
                          inc    ebx

    _next:                
                          inc    esi
                          jmp    phone_loop

    checkPhoneCount:      
                          cmp    ebx, 3
                          jl     _invalid

                          mov    eax, 1
                          pop    ebx
                          pop    esi
                          ret

    _invalid:             
                          mov    eax, 0
                          pop    ebx
                          pop    esi
                          ret
ValidatePhone ENDP

ValidateEmail PROC
                          push   esi
                          push   ebx
                          push   ecx
                          mov    esi, edx
                          xor    ebx, ebx
                          xor    ecx, ecx
    
    find_at:              
                          mov    al, [esi]
                          cmp    al, 0
                          je     check_at
    
                          cmp    al, '@'
                          jne    find_next
    
                          inc    ebx
                          mov    ecx, esi
    
    find_next:            
                          inc    esi
                          jmp    find_at
    
    check_at:             
                          cmp    ebx, 1
                          jne    _invalid
    
                          cmp    ecx, edx
                          je     _invalid
    
                          mov    esi, ecx
                          inc    esi
                          xor    ebx, ebx
    
    find_dot:             
                          mov    al, [esi]
                          cmp    al, 0
                          je     check_dot
    
                          cmp    al, '.'
                          jne    dot_next
    
                          inc    ebx
    
    dot_next:             
                          inc    esi
                          jmp    find_dot
    
    check_dot:            
                          cmp    ebx, 1
                          jl     _invalid
    
                          dec    esi
                          mov    al, [esi]
                          cmp    al, '.'
                          je     _invalid
                          cmp    al, '@'
                          je     _invalid
    
                          mov    eax, 1
                          pop    ecx
                          pop    ebx
                          pop    esi
                          ret
    
    _invalid:             
                          mov    eax, 0
                          pop    ecx
                          pop    ebx
                          pop    esi
                          ret
ValidateEmail ENDP

ReadValidatedString PROC
                          push   ebx
                          push   edi
                          push   esi
    
                          mov    ebx, edx
    
    retry_input:          
                          mov    edx, ebx
                          push   ecx
                          call   ReadString
                          pop    ecx
    
                          mov    byte ptr [ebx + eax], 0
    
                          push   edx
                          mov    edx, ebx
                          push   eax
                          call   ValidateNotEmpty
                          pop    ecx
                          pop    edx
    
                          cmp    eax, 0
                          je     show_empty_error
    
                          cmp    esi, 0
                          je     input_success
    
                          push   edx
                          mov    edx, ebx
                          push   ecx
                          call   esi
                          pop    ecx
                          pop    edx
    
                          cmp    eax, 0
                          je     show_validation_error
    
    input_success:        
                          mov    eax, ecx
                          clc
                          pop    esi
                          pop    edi
                          pop    ebx
                          ret
    
    show_empty_error:     
                          mov    edx, OFFSET emptyInputMsg
                          call   WriteString
                          jmp    ask_retry
    
    show_validation_error:
                          mov    edx, edi
                          call   WriteString
    
    ask_retry:            
                          mov    edx, OFFSET retryPrompt
                          call   WriteString
                          call   ReadChar
                          call   Crlf
    
                          cmp    al, 'C'
                          je     input_cancelled
                          cmp    al, 'c'
                          je     input_cancelled
    
                          jmp    retry_input
    
    input_cancelled:      
                          xor    eax, eax
                          stc
                          pop    esi
                          pop    edi
                          pop    ebx
                          ret
ReadValidatedString ENDP


END main