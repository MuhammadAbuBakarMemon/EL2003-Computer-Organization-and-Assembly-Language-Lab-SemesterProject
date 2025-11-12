INCLUDE Irvine32.inc

.data

;Constants
Max_Contacts = 20
Name_Size = 30
Ph_Num_Size = 15
Addr_Size = 50
Email_Size = 30

;variables
names DB Max_Contacts * Name_Size DUP(?)
nums DB	Max_Contacts * Ph_Num_Size DUP(?)
addrs DB Max_Contacts * Addr_Size DUP(?)
emails DB Max_Contacts * Email_Size DUP(?)
Contact_Count DW 0

; prompts
MenuHeader DB " ----- Main Menu ----- ",0Dh,0Ah,0
MenuList DB 0Dh,0Ah,"1. Add",0Dh,0Ah,"2. Update",0Dh,0Ah,"3. Display",0Dh,0Ah,"4. Delete",0Dh,0Ah,"5. Search",0Dh,0Ah,"6. Exit Directory",0Dh,0Ah,0
MenuChoice DB ?

InvalidMenuChoice DB 0Dh,0Ah,"Invalid Choice!",0Dh,0Ah,0

; messages
MenuChoiceMsg DB 0Dh,0Ah,"Enter your Choice: ",0
exitProgramMsg DB 0Dh,0Ah,"Exiting...",0
continueMsg DB 0Dh,0Ah,"Press any key to continue...",0

_Wait PROTO
_ClrScr PROTO
.code 

main PROC
top:
    mov edx, OFFSET MenuHeader
    call WriteString
    mov edx, OFFSET MenuList
    call WriteString
    mov edx, OFFSET MenuChoiceMsg
    call WriteString
    call ReadInt

    cmp eax, 1
    je _add
    cmp eax, 2
    je _update
    cmp eax, 3
    je _display
    cmp eax, 4
    je _delete
    cmp eax, 5
    je _search
    cmp eax, 6
    je _exit

    mov edx, OFFSET InvalidMenuChoice
    call WriteString
    jmp _refresh

_add:
    call WriteDec
    jmp _refresh
_update:
    call WriteDec
    jmp _refresh
_display:
    call WriteDec
    jmp _refresh
_delete:
    call WriteDec
    jmp _refresh
_search:
    call WriteDec
    jmp _refresh

_refresh:
    call _Wait
    call _Clrscr
    jmp top

_exit:
    Exit
main ENDP

_Wait PROC 
    mov edx, offset continueMsg
    call WriteString 
    call readchar
ret
_Wait ENDP
_clrscr proc
    mov dh, 0
    mov dl, 0
    call gotoxy

    mov ecx, 80*25
    mov al, ' '
ClearLoop:
    call WriteChar
    loop ClearLoop

    mov dh, 0
    mov dl, 0

    call gotoxy
    ret
_clrscr endp

AddContact PROC
ret
AddContact ENDP


end main 
