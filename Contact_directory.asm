INCLUDE Irvine32.inc

.data

    ;Constants
    Max_Contacts      =       20
    Name_Size         =       30
    Ph_Num_Size       =       15
    Addr_Size         =       50
    Email_Size        =       30

    ;variables
    names             DB      Max_Contacts * Name_Size DUP(?)
    nums              DB      Max_Contacts * Ph_Num_Size DUP(?)
    addrs             DB      Max_Contacts * Addr_Size DUP(?)
    emails            DB      Max_Contacts * Email_Size DUP(?)
    Contact_Count     DW      19


    ; prompts
    MenuHeader        DB      " ----- Main Menu ----- ",0Dh,0Ah,0
    MenuList          DB      0Dh,0Ah,"1. Add",0Dh,0Ah,"2. Update",0Dh,0Ah,"3. Display",0Dh,0Ah,"4. Delete",0Dh,0Ah,"5. Search",0Dh,0Ah,"6. Exit Directory",0Dh,0Ah,0
    MenuChoice        DB      ?

    InvalidMenuChoice DB      0Dh,0Ah,"Invalid Choice!",0Dh,0Ah,0

    NamePrompt        DB      "Name: ",0
    PhPrompt          DB      "Phone Number: ",0
    AddrPrompt        DB      "Address: ",0
    EmailPrompt       DB      "Email: ",0

    ; messages
    MenuChoiceMsg     DB      0Dh,0Ah,"Enter your Choice: ",0
    exitProgramMsg    DB      0Dh,0Ah,"Exiting...",0
    continueMsg       DB      0Dh,0Ah,"Press any key to continue...",0

    addMsg            DB      "Enter Following Details: ",0
    addedMsg          DB      0Dh,0Ah,"-- Contact has been added to the directory. --",0Dh,0Ah,0
    dirFullMsg        DB      0Dh,0Ah,"Contact Directory is Full! No more contacts can be added.",0Dh,0Ah,0


                      _Wait   PROTO
                      _ClrScr PROTO

.code

main PROC
    top:        
                mov    edx, OFFSET MenuHeader
                call   WriteString
                mov    edx, OFFSET MenuList
                call   WriteString
                mov    edx, OFFSET MenuChoiceMsg
                call   WriteString
                call   ReadInt

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
    ;call WriteDec
                jmp    _refresh
    _update:    
                call   WriteDec
                jmp    _refresh
    _display:   
                call   WriteDec
                jmp    _refresh
    _delete:    
                call   WriteDec
                jmp    _refresh
    _search:    
                call   WriteDec
                jmp    _refresh

    _refresh:   
                call   _Wait
                call   _ClrScr
                jmp    top

    _exit:      
                Exit
main ENDP

_Wait PROC
                mov    edx, offset continueMsg
                call   WriteString
                call   readchar
                ret
_Wait ENDP

_ClrScr PROC
                mov    dh, 0
                mov    dl, 0
                call   gotoxy

                mov    ecx, 100*40
                mov    al, ' '
    ClearLoop:  
                call   WriteChar
                loop   ClearLoop

                mov    dh, 0
                mov    dl, 0

                call   gotoxy
                ret
_ClrScr ENDP

AddContact PROC
                mov    ax, Contact_Count
                cmp    ax, Max_Contacts
                jae    dirFull

                mov    edx, offset addMsg
                call   writestring
                call   crlf

    ;Add Name
                movzx  eax, Contact_Count
                mov    ebx, eax
                imul   ebx, Name_Size
                lea    edi, names[ebx]

                mov    edx, offset NamePrompt
                call   writestring
                mov    edx, edi
                mov    ecx, Name_Size
                call   readstring

    ;Add Phone Number
                movzx  eax, Contact_Count
                mov    ebx, eax
                imul   ebx, Ph_Num_Size
                lea    edi, nums[ebx]

                mov    edx, offset PhPrompt
                call   writestring
                mov    edx, edi
                mov    ecx, Ph_Num_Size
                call   readstring

    ;Add Address
                movzx  eax, Contact_Count
                mov    ebx, eax
                imul   ebx, Addr_Size
                lea    edi, addrs[ebx]

                mov    edx, offset AddrPrompt
                call   writestring
                mov    edx, edi
                mov    ecx, Addr_Size
                call   readstring

    ;Add Emails
                movzx  eax, Contact_Count
                mov    ebx, eax
                imul   ebx, Email_Size
                lea    edi, emails[ebx]

                mov    edx, offset EmailPrompt
                call   writestring
                mov    edx, edi
                mov    ecx, email_Size
                call   readstring

                inc    Contact_Count

                mov    edx, offset addedMsg
                call   writestring
                ret

    dirFull:    
                mov    edx, offset dirFullMsg
                call   writeString
   
                ret
AddContact ENDP

SortContact Proc
                pushad
    
                mov    ax, Contact_Count
                cmp    ax, 1
                jbe    doneSorting

                mov    cx, ax
                dec    cx

    outerloop:  
                mov    bx, 0

    innerloop:  
                mov    dx, Contact_Count
                dec    dx
                sub    dx, bx
                jbe    nextPass

    ;compare names[i] and names[i+1]
                movzx  esi, bx
                imul   esi, Name_Size
                lea    esi, names[esi]

                movzx  edi, bx
                inc    edi
                imul   edi, Name_Size
                lea    edi, names[edi]

                mov    ecx, Name_Size
                push   bx
                push   cx

                mov    eax, 0
    compareloop:
                mov    al, [esi]
                mov    ah, [edi]
                cmp    al, ah
                jne    foundDiff
                cmp    al, 0
                je     sameNames
                inc    esi
                inc    edi
                loop   compareloop

                jmp    sameNames

    foundDiff:  
                jae    noSwap

                pop    cx
                pop    bx
                push   bx

    ;swap names
                movzx  esi, bx
                imul   esi, Name_Size
                lea    esi, names[esi]

                movzx  edi,bx
                inc    edi
                imul   edi, Name_Size
                lea    edi, names[esi]

                mov    ecx, Name_Size
                call   swapblock

    ;swap phone numbers
                movzx  esi, bx
                imul   esi, Ph_Num_Size
                lea    esi, nums[esi]

                movzx  edi, bx
                inc    edi
                imul   edi, Ph_Num_Size
                lea    edi, nums[edi]

                mov    ecx, Ph_Num_Size
                call   swapblock

    ;swap addresses
                movzx  esi, bx
                imul   esi, Addr_Size
                lea    esi, addrs[esi]

                movzx  edi, bx
                inc    edi
                imul   edi, Addr_Size
                lea    edi, addrs[edi]

                mov    ecx, Addr_Size
                call   swapblock

    ;swap emails
                movzx  esi, bx
                imul   esi, Email_Size
                lea    esi, emails[esi]

                movzx  edi, bx
                inc    edi
                imul   edi, Email_Size
                lea    edi, emails[edi]

                mov    ecx, Email_Size
                call   swapblock

    noSwap:     
    sameNames:  
                pop    cx
                pop    bx
                inc    bx
                jmp    innerloop

    nextPass:   
                loop   outerloop

    doneSorting:
                mov    edx, offset doneSortMsg
                call   WriteString
                call   readchar
                popad

                ret
SortContact Proc

end main 
