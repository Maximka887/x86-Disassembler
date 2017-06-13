;*****************************************************************************************************
;Paleidimo parametru nuskaitymas bei failu pavadinimu irasymas
;*****************************************************************************************************
PROC paleidimo_parametrai
	xor ch,ch
	mov cl, es:[0080h]
	cmp cl, 0
	je spausd_info
	mov bx, 0081h ; programos paleidimo parametrai saugomi es segmente pradedant 81h baitu
	mov di, 0
	
Seek_par: ;iesko paleidimo parametrus kaip /?, ir issaugo ivedimo failo pavadinima
	mov al,es:[bx]
	inc bx
	
	cmp word ptr es:[bx-1], '?/'
	je spausd_info
	
	cmp al, 13d
	je spausd_info
	
	cmp al, ' '
	je Seek_par
	
	mov byte ptr ds:[input_file_name+di], al
	inc di
	
	cmp byte ptr es:[bx],' '
	je input_failo_vardo_pabaiga
	jmp seek_par

input_failo_vardo_pabaiga:
	mov byte ptr ds:[input_file_name+di], 0
	mov di, 0
	inc bx
	
seek_par_2: ; issaugo isvedimo failo pavadinima
	mov al, es:[bx]
	inc bx
	
	cmp al, 13d
	je spausd_info
	
	cmp al, ' '
	je Seek_par_2
	
	mov byte ptr ds:[output_file_name+di], al
	inc di
	
	cmp byte ptr es:[bx], 13d
	je output_failo_vardo_pabaiga
	jmp seek_par_2
	
output_failo_vardo_pabaiga:
	mov byte ptr ds:[output_file_name+di],'.'
	mov byte ptr ds:[output_file_name+di+1],'a'
	mov byte ptr ds:[output_file_name+di+2],'s'
	mov byte ptr ds:[output_file_name+di+3],'m'
	mov byte ptr ds:[output_file_name+di+4], 0
	jmp paleid_par_pabaiga
	
spausd_info:
	mov ah, 09h
	mov dx, offset help_message
	int 21h
	call exit_program
	
paleid_par_pabaiga:
ret
ENDP paleidimo_parametrai
;*****************************************************************************************************
;Isejimo procedura
;*****************************************************************************************************
PROC exit_program
	mov ah, 04Ch
	int 21h
ENDP exit_program
;*****************************************************************************************************
;failu uzdarymo procedura
;*****************************************************************************************************
PROC fclose
		
		mov ah, 03Eh
		mov bx, input_file_handle
		int 21h
		jnc fclose_toliau
		mov al, 2
		call error_processing
	
fclose_toliau:		
		mov bx, output_file_handle
		int 21h
		jc fclose_error
		
	call exit_program
	
fclose_error:
	mov al, 4
	call error_processing
	
	ret
endp fclose
;*****************************************************************************************************
;failu sukurimas ir atidarymas darbui
;*****************************************************************************************************

PROC failu_apdorojimas_darbui
	
	mov al, 0h
	mov ah, 03Dh
	mov dx, offset input_file_name
	int 21h
	JC failed_to_open
	mov input_file_handle, ax
	
	mov ah, 03Ch
	mov dx, offset output_file_name
	int 21h
	JC failed_to_create

	mov ah, 03Dh
	mov al, 01h
	int 21h
	JC failed_to_open2
	mov output_file_handle, ax
	
	ret
	
failed_to_open:
	mov al, 1h
	call error_processing

failed_to_open2:
	mov al, 3h
	call error_processing
	
failed_to_create:
	mov al, 5h
	call error_processing
endp failu_apdorojimas_darbui

;*****************************************************************************************************
;klaidu apdorojimo procedura
;*****************************************************************************************************
PROC error_processing
	mov ah, 09h
	
	cmp al, 1h
	je input_error1
	
	cmp al, 2h
	je input_error2
	
	cmp al, 3h
	je output_error1
	
	cmp al, 4h
	je output_error2
	
	cmp al, 5h
	je output_error3
	
	cmp al, 6h
	je error_while_reading_file
	
	cmp al, 7h
	je error_while_writing_file
	
	jmp error_processing_end

input_error1: ;1
	mov dx, offset input_open_error_message
	int 21h
	jmp error_processing_end
	
input_error2: ;2
	mov dx, offset input_close_error_message
	int 21h
	jmp error_processing_end
	
output_error1: ;3
	mov dx, offset output_open_error_message
	int 21h
	jmp error_processing_end
	
output_error2: ;4
	mov dx, offset output_close_error_message
	int 21h
	jmp error_processing_end
	
output_error3: ;5
	mov dx, offset output_create_error_message
	int 21h
	jmp error_processing_end

error_while_reading_file: ;6
	mov dx, offset reading_error_message
	int 21h
	jmp error_processing_end
	
error_while_writing_file: ;7
	mov dx, offset writing_error_message
	int 21h
	jmp error_processing_end
	
error_processing_end:
	call exit_program
endp error_processing	
;*****************************************************************************************************
;po komandos atpazinimo ir uzrasymo nunulina visas parametru reiksmes
;*****************************************************************************************************
PROC zero_parameters

	mov byte ptr [prefix_used],0 
	mov byte ptr [prefix_byte], 0 
	mov byte ptr [first_byte], 0 
	mov byte ptr [second_byte], 0  
	mov byte ptr [third_byte], 0 
	mov byte ptr [fourth_byte], 0 
	mov byte ptr [sixth_byte],0 

	mov byte ptr [d_bit],0 
	mov byte ptr [w_bit],0 

	mov byte ptr [ab_mod], 0
	mov byte ptr [ab_reg],0 
	mov byte ptr [ab_rm],0 
	
	mov byte ptr [byte_count],0 
	mov byte ptr [format_nr], 0 
	
	mov byte ptr [current_byte],0 
	ret
endp zero_parameters