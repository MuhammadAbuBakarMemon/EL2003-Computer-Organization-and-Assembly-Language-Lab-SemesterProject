INCLUDE c:\Users\Dell\.vscode\extensions\istareatscreens.masm-runner-0.9.1\native\irvine\Irvine32.inc

; ---------------------------------------------------------
; STRUCT DEFINITION
; ---------------------------------------------------------
Contact STRUCT
    personName  BYTE 30 DUP(?)    ; Name_Size
    phone       BYTE 15 DUP(?)    ; Ph_Num_Size
    address     BYTE 100 DUP(?)   ; Addr_Size
    email       BYTE 30 DUP(?)    ; Email_Size
Contact ENDS

.data

    ; Constants
    Max_Contacts      =         50
    
    ; Storage (Array of Structs)
                      directory Contact Max_Contacts DUP(<>)
    Contact_Count     DD        0

    ; Temporary buffers
    tempBuf           DB        100 DUP(?)                                                                                                                                                      ; Size of largest field (Address)

    ; Prompts / Messages
    MenuHeader        DB        " ----- Main Menu ----- ",0Dh,0Ah,0
    MenuList          DB        0Dh,0Ah,"1. Add",0Dh,0Ah,"2. Update ",0Dh,0Ah,"3. Display",0Dh,0Ah,"4. Delete",0Dh,0Ah,"5. Search",0Dh,0Ah,"6. Exit Directory",0Dh,0Ah,0
    MenuChoiceMsg     DB        0Dh,0Ah,"Enter your Choice: ",0
    InvalidMenuChoice DB        0Dh,0Ah,"Invalid Choice!",0Dh,0Ah,0

    NamePrompt        DB        "Name: ",0
    PhPrompt          DB        "Phone Number: ",0
    AddrPrompt        DB        "Address: ",0
    EmailPrompt       DB        "Email: ",0

    addMsg            DB        "Enter Following Details: ",0
    addedMsg          DB        0Dh,0Ah,"-- Contact has been added. --",0Dh,0Ah,0
    dirFullMsg        DB        0Dh,0Ah,"Directory is Full!",0Dh,0Ah,0
    continueMsg       DB        0Dh,0Ah,"Press any key to continue...",0

    emptyInputMsg     DB        0Dh,0Ah,"Error: Input cannot be empty!",0Dh,0Ah,0
    invalidNameMsg    DB        0Dh,0Ah,"Error: Letters and spaces only",0Dh,0Ah,0
    invalidPhoneMsg   DB        0Dh,0Ah,"Error: Digits, +, - only!",0Dh,0Ah,0
    invalidEmailMsg   DB        0Dh,0Ah,"Error: Invalid Email Format", 0Dh,0Ah,0
    retryPrompt       DB        0Dh,0Ah,"Press Enter to retry or 'C' to Cancel: ",0

    doneSortMsg       DB        0Dh,0Ah,"-- Contacts sorted. --",0Dh,0Ah,0
    displayEmptyMsg   DB        0Dh,0Ah,"-- Directory is empty. --",0Dh,0Ah,0
    contactHeader     DB        0Dh,0Ah,"Contact #: ",0
    contactDiv        DB        0Dh,0Ah,"------------------------------",0Dh,0Ah,0

    delPrompt         DB        0Dh,0Ah,"Enter Contact # to delete: ",0
    delConfirmMsg     DB        0Dh,0Ah,"-- Contact deleted. --",0Dh,0Ah,0
    delErrEmpty       DB        0Dh,0Ah,"Error: Directory empty.",0Dh,0Ah,0
    delErrInvalid     DB        0Dh,0Ah,"Error: Invalid Contact #.",0Dh,0Ah,0

    searchPrompt      DB        0Dh,0Ah,"Enter Name to Search: ",0
    searchFoundMsg    DB        0Dh,0Ah,"--- Contact Found ---",0Dh,0Ah,0
    searchNotFoundMsg DB        0Dh,0Ah,"-- Contact not found. --",0Dh,0Ah,0

                      lowIdx    SDWORD ?
                      highIdx   SDWORD ?
                      midIdx    SDWORD ?

    ; Update Strings
    UpdatePrompt      DB        0Dh,0Ah,"Enter contact number to update: ",0
    UpdateMenuList    DB        0Dh,0Ah,"Update Options:",0Dh,0Ah,"1. Name",0Dh,0Ah,"2. Phone",0Dh,0Ah,"3. Address",0Dh,0Ah,"4. Email",0Dh,0Ah,"5. All Fields",0Dh,0Ah,"6. Cancel",0Dh,0Ah,0
    UpdateChoiceMsg   DB        0Dh,0Ah,"Choose field: ",0
    updatedMsg        DB        0Dh,0Ah,"-- Contact updated. --",0Dh,0Ah,0
    updateCancelMsg   DB        0Dh,0Ah,"-- Canceled. --",0Dh,0Ah,0
    invalidIndexMsg   DB        0Dh,0Ah,"Invalid contact number!",0Dh,0Ah,0

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
                            call   ReadChar
                            call   Crlf
                            sub    al, '0'
                            movzx  eax, al

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
                            call   DeleteContact
                            jmp    _refresh
    _search:                
                            call   SearchContact
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

    ; ---------------------------------------------------------
    ; AddContact
    ; ---------------------------------------------------------
AddContact PROC
                            mov    eax, Contact_Count
                            cmp    eax, Max_Contacts
                            jae    dirFull

                            mov    edx, OFFSET addMsg
                            call   WriteString
                            call   Crlf

    ; Calculate offset for the new contact: directory[Contact_Count]
                            mov    ebx, Contact_Count
                            imul   ebx, TYPE Contact
                            lea    edi, directory[ebx]                                 ; EDI points to base of current contact struct

    ; 1. Name
                            mov    edx, OFFSET NamePrompt
                            call   WriteString
    
                            lea    edx, (Contact PTR [edi]).personName                 ; Point to personName field
                            mov    ecx, LENGTHOF (Contact PTR [edi]).personName - 1
                            mov    esi, OFFSET ValidateName
                            push   edi                                                 ; Save struct base
                            mov    edi, OFFSET invalidNameMsg
                            call   ReadValidatedString
                            pop    edi                                                 ; Restore struct base
                            jc     add_cancelled

    ; 2. Phone
                            mov    edx, OFFSET PhPrompt
                            call   WriteString
    
                            lea    edx, (Contact PTR [edi]).phone
                            mov    ecx, LENGTHOF (Contact PTR [edi]).phone - 1
                            mov    esi, OFFSET ValidatePhone
                            push   edi
                            mov    edi, OFFSET invalidPhoneMsg
                            call   ReadValidatedString
                            pop    edi
                            jc     add_cancelled

    ; 3. Address
                            mov    edx, OFFSET AddrPrompt
                            call   WriteString
    
                            lea    edx, (Contact PTR [edi]).address
                            mov    ecx, LENGTHOF (Contact PTR [edi]).address - 1
                            xor    esi, esi                                            ; No special regex validation
                            xor    edi, edi                                            ; No error msg needed
    ; Note: EDI is currently 0, we lost struct base pointer in EDI,
    ; but ReadValidatedString restores registers it pushes,
    ; however we passed EDI as 0. Safe because we re-calc base later or use saved EBX if needed.
    ; Actually, let's just recalculate pointer if needed, but here ReadValidatedString does the job.
                            call   ReadValidatedString
                            jc     add_cancelled

    ; Restore base pointer for Email
                            mov    ebx, Contact_Count
                            imul   ebx, TYPE Contact
                            lea    edi, directory[ebx]

    ; 4. Email
                            mov    edx, OFFSET EmailPrompt
                            call   WriteString
    
                            lea    edx, (Contact PTR [edi]).email
                            mov    ecx, LENGTHOF (Contact PTR [edi]).email - 1
                            mov    esi, OFFSET ValidateEmail
                            push   edi
                            mov    edi, OFFSET invalidEmailMsg
                            call   ReadValidatedString
                            pop    edi
                            jc     add_cancelled

    ; Success
                            inc    Contact_Count
                            mov    edx, OFFSET addedMsg
                            call   WriteString
                            call   SortContact
                            ret

    add_cancelled:          
                            mov    edx, OFFSET updateCancelMsg
                            call   WriteString
                            call   SortContact
                            ret

    dirFull:                
                            mov    edx, OFFSET dirFullMsg
                            call   WriteString
                            ret
AddContact ENDP

    ; ---------------------------------------------------------
    ; SortContact - Bubble Sort by Name
    ; ---------------------------------------------------------
SortContact PROC
                            pushad
                            mov    eax, Contact_Count
                            cmp    eax, 2
                            jb     doneSorting

                            dec    eax
                            mov    ecx, eax                                            ; Outer loop N-1

    outer_loop:             
                            push   ecx
                            mov    ebx, 0                                              ; Index i = 0
                            mov    edx, ecx                                            ; Limit

    inner_loop:             
                            cmp    ebx, edx
                            jae    inner_done_pass

    ; Calculate pointers to contacts[i] and contacts[i+1]
                            mov    esi, ebx
                            imul   esi, TYPE Contact
                            lea    esi, directory[esi]                                 ; ESI = &contacts[i]

                            mov    edi, ebx
                            inc    edi
                            imul   edi, TYPE Contact
                            lea    edi, directory[edi]                                 ; EDI = &contacts[i+1]

    ; Compare Names
                            push   esi
                            push   edi
    
    ; Setup specific field pointers
                            lea    esi, (Contact PTR [esi]).personName
                            lea    edi, (Contact PTR [edi]).personName
    
                            INVOKE Str_compare, esi, edi
                            pop    edi
                            pop    esi

                            ja     do_swap                                             ; If name[i] > name[i+1], swap
                            jmp    no_swap

    do_swap:                
    ; Swap entire Contact Structs
    ; ESI points to Struct A, EDI points to Struct B
                            mov    ecx, TYPE Contact                                   ; Size of entire struct
                            call   swapblock

    no_swap:                
                            inc    ebx
                            jmp    inner_loop

    inner_done_pass:        
                            pop    ecx
                            dec    ecx
                            jnz    outer_loop

    doneSorting:            
                            mov    edx, OFFSET doneSortMsg
                            call   WriteString
                            popad
                            ret
SortContact ENDP

    ; ---------------------------------------------------------
    ; swapblock - swaps ECX bytes between [ESI] and [EDI]
    ; ---------------------------------------------------------
swapblock PROC
                            push   esi
                            push   edi
                            push   ecx
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

    ; ---------------------------------------------------------
    ; DisplayContacts
    ; ---------------------------------------------------------
DisplayContacts PROC
    pushad
    mov    eax, Contact_Count
    cmp    eax, 0
    je     display_empty

    mov    ebx, 0                  ; Loop index
    lea    esi, directory          ; Pointer to start of array

display_loop:
    ; Print separator using default color
    mov    eax, 07h                ; Light gray
    call   SetTextColor
    mov    edx, OFFSET contactDiv
    call   WriteString

    ; Print header using default color
    mov    eax, 07h
    call   SetTextColor
    mov    edx, OFFSET contactHeader
    call   WriteString
    mov    eax, ebx
    inc    eax
    call   WriteInt
    call   Crlf

    ; Set color for contact fields
    mov    al, (Contact PTR [esi]).c_label
    cmp    al, 1
    je     set_green
    cmp    al, 2
    je     set_red
    jmp    set_default

set_green:
    mov    eax, 0Ah                ; Green
    call   SetTextColor
    jmp    show_contact_fields

set_red:
    mov    eax, 0Ch                ; Red
    call   SetTextColor
    jmp    show_contact_fields

set_default:
    mov    eax, 07h                ; Default (light gray)
    call   SetTextColor

show_contact_fields:
    ; Name with label
    mov    edx, OFFSET NamePrompt
    call   WriteString
    lea    edx, (Contact PTR [esi]).personName
    call   WriteString

    mov    al, (Contact PTR [esi]).c_label
    cmp    al, 1
    je     show_friend_str
    cmp    al, 2
    je     show_fav_str
    jmp    show_label_done
show_friend_str:
    mov    edx, OFFSET FriendStr
    call   WriteString
    jmp    show_label_done
show_fav_str:
    mov    edx, OFFSET FavouriteStr
    call   WriteString
show_label_done:
    call   Crlf

    ; Phone
    mov    edx, OFFSET PhPrompt
    call   WriteString
    lea    edx, (Contact PTR [esi]).phone
    call   WriteString
    call   Crlf

    ; Address
    mov    edx, OFFSET AddrPrompt
    call   WriteString
    lea    edx, (Contact PTR [esi]).address
    call   WriteString
    call   Crlf

    ; Email
    mov    edx, OFFSET EmailPrompt
    call   WriteString
    lea    edx, (Contact PTR [esi]).email
    call   WriteString
    call   Crlf

    ; Reset color before next separator
    mov    eax, 07h
    call   SetTextColor

    ; Move to next struct
    add    esi, TYPE Contact
    inc    ebx
    cmp    ebx, Contact_Count
    jl     display_loop

    mov    eax, 07h
    call   SetTextColor
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

    ; ---------------------------------------------------------
    ; UpdateContacts
    ; ---------------------------------------------------------
UpdateContacts PROC
                            pushad
                            mov    eax, Contact_Count
                            cmp    eax, 0
                            je     uc_display_empty

                            call   DisplayContacts

                            mov    edx, OFFSET UpdatePrompt
                            call   WriteString
                            call   ReadInt
                            mov    ebx, eax
    
                            cmp    ebx, 1
                            jl     uc_invalid_index
                            cmp    ebx, Contact_Count
                            jg     uc_invalid_index

                            dec    ebx                                                 ; 0-based index

    ; Calculate pointer to selected contact
                            imul   ebx, TYPE Contact
                            lea    esi, directory[ebx]                                 ; ESI = Pointer to Contact Struct

    ; Show current values
                            mov    edx, OFFSET NamePrompt
                            call   WriteString
                            lea    edx, (Contact PTR [esi]).personName
                            call   WriteString
                            call   Crlf
    
    ; (Skipping display of others for brevity, typically you'd show all)

                            mov    edx, OFFSET UpdateMenuList
                            call   WriteString
                            mov    edx, OFFSET UpdateChoiceMsg
                            call   WriteString
                            call   ReadInt
    
                            cmp    eax, 6
                            je     uc_cancel
    
    ; ESI holds struct pointer. We use it to get offsets.

                            cmp    eax, 1
                            je     uc_name
                            cmp    eax, 2
                            je     uc_phone
                            cmp    eax, 3
                            je     uc_addr
                            cmp    eax, 4
                            je     uc_email
                            cmp    eax, 5
                            je     uc_all
                            jmp    uc_done

    uc_name:                
                            lea    edi, (Contact PTR [esi]).personName
                            mov    ecx, LENGTHOF (Contact PTR [esi]).personName - 1
                            mov    edx, OFFSET NamePrompt
                            call   HelperUpdateField
                            jmp    uc_updated

    uc_phone:               
                            lea    edi, (Contact PTR [esi]).phone
                            mov    ecx, LENGTHOF (Contact PTR [esi]).phone - 1
                            mov    edx, OFFSET PhPrompt
                            call   HelperUpdateField
                            jmp    uc_updated

    uc_addr:                
                            lea    edi, (Contact PTR [esi]).address
                            mov    ecx, LENGTHOF (Contact PTR [esi]).address - 1
                            mov    edx, OFFSET AddrPrompt
                            call   HelperUpdateField
                            jmp    uc_updated

    uc_email:               
                            lea    edi, (Contact PTR [esi]).email
                            mov    ecx, LENGTHOF (Contact PTR [esi]).email - 1
                            mov    edx, OFFSET EmailPrompt
                            call   HelperUpdateField
                            jmp    uc_updated

    uc_all:                 
    ; Name
                            lea    edi, (Contact PTR [esi]).personName
                            mov    ecx, LENGTHOF (Contact PTR [esi]).personName - 1
                            mov    edx, OFFSET NamePrompt
                            call   HelperUpdateField

    ; Phone
                            lea    edi, (Contact PTR [esi]).phone
                            mov    ecx, LENGTHOF (Contact PTR [esi]).phone - 1
                            mov    edx, OFFSET PhPrompt
                            call   HelperUpdateField

    ; Address
                            lea    edi, (Contact PTR [esi]).address
                            mov    ecx, LENGTHOF (Contact PTR [esi]).address - 1
                            mov    edx, OFFSET AddrPrompt
                            call   HelperUpdateField

    ; Email
                            lea    edi, (Contact PTR [esi]).email
                            mov    ecx, LENGTHOF (Contact PTR [esi]).email - 1
                            mov    edx, OFFSET EmailPrompt
                            call   HelperUpdateField
                            jmp    uc_updated

    uc_updated:             
                            mov    edx, OFFSET updatedMsg
                            call   WriteString
                            call   SortContact
                            jmp    uc_end

    uc_cancel:              
                            mov    edx, OFFSET updateCancelMsg
                            call   WriteString
                            jmp    uc_end

    uc_invalid_index:       
                            mov    edx, OFFSET invalidIndexMsg
                            call   WriteString
                            jmp    uc_end

    uc_display_empty:       
                            mov    edx, OFFSET displayEmptyMsg
                            call   WriteString

    uc_done:                
    uc_end:                 
                            popad
                            ret
UpdateContacts ENDP

    ; Helper to read into temp and copy if not empty
    ; Inputs: EDX = Prompt, EDI = Dest Ptr, ECX = Max Len
HelperUpdateField PROC
                            pushad
                            call   WriteString                                         ; Print prompt
    
    ; Read into tempBuf
                            push   edi                                                 ; Save dest
                            mov    edx, OFFSET tempBuf
    ; ECX is already set
                            call   ReadString
                            mov    byte ptr [tempBuf + eax], 0
                            pop    edi                                                 ; Restore dest

                            cmp    eax, 0
                            je     no_update

    ; Copy tempBuf to EDI
                            mov    esi, OFFSET tempBuf
                            inc    eax                                                 ; include null
                            mov    ecx, eax
                            cld
                            rep    movsb

    no_update:              
                            popad
                            ret
HelperUpdateField ENDP

    ; ---------------------------------------------------------
    ; DeleteContact
    ; ---------------------------------------------------------
DeleteContact PROC
                            pushad
                            mov    eax, Contact_Count
                            cmp    eax, 0
                            je     del_empty

                            mov    edx, OFFSET delPrompt
                            call   WriteString
                            call   ReadInt
    
                            cmp    eax, 1
                            jl     del_invalid
                            cmp    eax, Contact_Count
                            jg     del_invalid

                            dec    eax                                                 ; Index to delete
                            mov    ebx, eax

    ; Calculate number of items to shift
    ; Count = (Total - Index - 1)
                            mov    ecx, Contact_Count
                            dec    ecx
                            sub    ecx, ebx
    
                            cmp    ecx, 0
                            je     del_decrement_only                                  ; Deleting last item, no shift needed

    ; Calculate pointers
    ; Dest: &directory[ebx]
                            mov    eax, ebx
                            imul   eax, TYPE Contact
                            lea    edi, directory[eax]

    ; Source: &directory[ebx+1]
                            lea    esi, [edi + TYPE Contact]

    ; Total bytes to move = Items * TYPE Contact
                            imul   ecx, TYPE Contact
    
                            cld
                            rep    movsb

    del_decrement_only:     
                            dec    Contact_Count
                            mov    edx, OFFSET delConfirmMsg
                            call   WriteString
                            jmp    del_exit

    del_empty:              
                            mov    edx, OFFSET delErrEmpty
                            call   WriteString
                            jmp    del_exit
    del_invalid:            
                            mov    edx, OFFSET delErrInvalid
                            call   WriteString
    del_exit:               
                            popad
                            ret
DeleteContact ENDP

    ; ---------------------------------------------------------
    ; SearchContact (Binary Search)
    ; ---------------------------------------------------------
SearchContact PROC
                            call   Clrscr
                            cmp    Contact_Count, 0
                            je     sc_not_found

                            mov    edx, OFFSET searchPrompt
                            call   WriteString
                            mov    edx, OFFSET tempBuf
                            mov    ecx, LENGTHOF directory.personName - 1
                            call   ReadString
                            mov    byte ptr [tempBuf + eax], 0
                            cmp    eax, 0
                            je     sc_exit

                            mov    lowIdx, 0
                            mov    eax, Contact_Count
                            dec    eax
                            mov    highIdx, eax

    sc_loop:                
                            mov    eax, lowIdx
                            cmp    eax, highIdx
                            jg     sc_not_found

                            add    eax, highIdx
                            sar    eax, 1
                            mov    midIdx, eax

    ; Get &directory[mid].personName
                            mov    ebx, midIdx
                            imul   ebx, TYPE Contact
                            lea    edi, (Contact PTR directory[ebx]).personName
                            mov    esi, OFFSET tempBuf

                            INVOKE Str_compare, esi, edi
                            je     sc_found
                            jb     sc_go_left
                            ja     sc_go_right

    sc_go_left:             
                            mov    eax, midIdx
                            dec    eax
                            mov    highIdx, eax
                            jmp    sc_loop

    sc_go_right:            
                            mov    eax, midIdx
                            inc    eax
                            mov    lowIdx, eax
                            jmp    sc_loop

    sc_found:               
                            mov    edx, OFFSET searchFoundMsg
                            call   WriteString
    
    ; Display found contact
                            mov    ebx, midIdx
                            imul   ebx, TYPE Contact
                            lea    esi, directory[ebx]                                 ; Pass struct pointer in ESI
                            call   DisplaySingleContactPtr
                            jmp    sc_exit

    sc_not_found:           
                            mov    edx, OFFSET searchNotFoundMsg
                            call   WriteString
    sc_exit:                
                            ret
SearchContact ENDP

    ; Helper to display contact pointed to by ESI
DisplaySingleContactPtr PROC
                            mov    edx, OFFSET NamePrompt
                            call   WriteString
                            lea    edx, (Contact PTR [esi]).personName
                            call   WriteString
                            call   Crlf

                            mov    edx, OFFSET PhPrompt
                            call   WriteString
                            lea    edx, (Contact PTR [esi]).phone
                            call   WriteString
                            call   Crlf

                            mov    edx, OFFSET AddrPrompt
                            call   WriteString
                            lea    edx, (Contact PTR [esi]).address
                            call   WriteString
                            call   Crlf

                            mov    edx, OFFSET EmailPrompt
                            call   WriteString
                            lea    edx, (Contact PTR [esi]).email
                            call   WriteString
                            call   Crlf
                            ret
DisplaySingleContactPtr ENDP

    ; ---------------------------------------------------------
    ; Validators (Slightly adjusted to take EDX as buffer)
    ; ---------------------------------------------------------
ValidateNotEmpty PROC
                            push   esi
                            mov    esi, edx
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

ValidateName PROC
                            push   esi
                            mov    esi, edx
    nameLoop:               
                            mov    al, [esi]
                            cmp    al, 0
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
                            mov    esi, edx
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
                            je     _pnext
                            cmp    al, '+'
                            je     _pnext
                            cmp    al, '-'
                            je     _pnext
                            jmp    _pinvalid
    digFound:               
                            inc    ebx
    _pnext:                 
                            inc    esi
                            jmp    phoneLoop
    checkPhoneCount:        
                            cmp    ebx, 3
                            jl     _pinvalid
                            mov    eax, 1
                            pop    ebx
                            pop    esi
                            ret
    _pinvalid:              
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
                            jne    find_next_e
                            inc    ebx
                            mov    ecx, esi
    find_next_e:            
                            inc    esi
                            jmp    find_at
    check_at:               
                            cmp    ebx, 1
                            jne    _einvalid
                            cmp    ecx, edx
                            je     _einvalid
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
                            jl     _einvalid
                            dec    esi
                            mov    al, [esi]
                            cmp    al, '.'
                            je     _einvalid
                            cmp    al, '@'
                            je     _einvalid
                            mov    eax, 1
                            pop    ecx
                            pop    ebx
                            pop    esi
                            ret
    _einvalid:              
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
                            mov    ebx, edx                                            ; EBX = Buffer Pointer
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
    
                            cmp    esi, 0                                              ; Check if validation proc provided
                            je     input_success
    
                            push   edx
                            mov    edx, ebx
                            push   ecx
                            call   esi                                                 ; Call validator
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
                            mov    edx, edi                                            ; Error message offset
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
