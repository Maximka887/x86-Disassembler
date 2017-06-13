.model small

buffersize		EQU 100h



.stack 100h

.data	


;****************************************************************************************************
;komandos  informacija
;****************************************************************************************************
	ip_word		dw 0100h
	
	prefix_used	db 0
	prefix_byte	db ?
	
	first_byte 	db ?
	second_byte db ?
	third_byte	db	?
	fourth_byte db ?
	fifth_byte	db ?
	sixth_byte 	db ?

	s_bit		db ?
	d_bit		db ?
	w_bit		db ?

	ab_mod		db ?
	ab_reg		db ?
	ab_rm		db ?
	
	byte_count	db 0
	format_nr 	db ?
	
	current_byte db ?
	
;****************************************************************************************************
;failu duomenys
;****************************************************************************************************

	input_file_handle	dw	?
	input_file_name		db	100 dup (?)
	input_file_end		db 	0
	
	output_file_handle 	dw ?
	output_file_name	db 100 dup (?)
	
	output_buffer	db	30h dup (?)
	input_buffer 	db	buffersize dup (?)
	byte_adress		dw	?
	carret_newline	db	13,10, "$"
	
;****************************************************************************************************
;Klaidu	apdorojimo pranesimai
;****************************************************************************************************

	error_number				db ? ; klaidu apdorojimo baitas
	input_open_error_message	db "Klaida atidarant faila skaitymui$"  ;1
	input_close_error_message	db "Klaida uzdarant faila skaitymui$"	;2
	output_open_error_message	db "Klaida atidarant faila rasymui$"	;3
	output_close_error_message	db "Klaida uzdarant faila rasymui$"		;4
	output_create_error_message db "Klaida sukuriant faila rasymui$"	;5
	reading_error_message		db "Klaida skaitant is failo$"			;6
	writing_error_message		db "Klaida irasant i faila$"			;7

;****************************************************************************************************
;Pagalbos pranesimai
;****************************************************************************************************	
	help_message 				db "Maksim Prokofjev, P.S. I kursas 4 grupe Dissasemblerio programa",10, 13
	help_message_2				db "Programa vercia masinini koda i assemblerio mnemonika", 10, 13, "$"

.code

include helper.asm

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
;*****************************************************************************************************
;iraso i buferi ip, uzpildo tarpais , ideda i reikiamas vietas tabus, ideda i gala cr ir nl
;*****************************************************************************************************
PROC output_bufferio_paruosimas
	push ax
	push bx
	push cx
	push dx
	
	mov di, offset output_buffer
	mov ax, ip_word
	xor dx,dx
	mov cx, 4
	mov bx, 10h
dalinam_ip:
	div bx
	push dx
	loop dalinam_ip
	mov cx, 4
	
idedam_ip_i_buferi:
	pop dx
	cmp dl,9
	ja raide
	add dl, 30h
	jmp idedam_ip
raide:
	add dl,55d
idedam_ip:
	mov byte ptr ds:[di],dl
	inc di
loop idedam_ip_i_buferi

	mov byte ptr ds:[di], ':'
	inc di
	mov byte ptr ds:[di],9d
	inc di
	
	mov cx, 28h
idedam_tarpus:
	mov byte ptr ds:[di],20h
	inc di
loop idedam_tarpus
	mov byte ptr ds:[di],13d
	inc di
	mov byte ptr ds:[di],10d
	
	mov di, offset output_buffer
	add di, 19d
	mov byte ptr ds:[di],9d
	add di, 5d
	mov byte ptr ds:[di],9d
	
	pop dx
	pop cx
	pop bx
	pop ax
ret
endp output_bufferio_paruosimas
;*****************************************************************************************************
;skaitymo is failo procedura
;*****************************************************************************************************
PROC bufferio_uzpildymas
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 03Fh
	mov bx,	input_file_handle
	mov cx, buffersize
	mov dx, offset input_buffer
	int 21h
	jc error_reading_file

	cmp cx, ax
	jb no_more_bytes
	jmp buferio_uzpildymas_end
	
	error_reading_file:
	mov al, 06d
	call error_processing
	
	no_more_bytes:
	mov input_file_end, 1d
	
	buferio_uzpildymas_end:
	mov byte_adress, dx
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
ENDP bufferio_uzpildymas
;*****************************************************************************************************
;gauna baita is buferio
;*****************************************************************************************************
PROC get_byte
	
	mov si, byte_adress
	mov di, byte_adress + buffersize
	xor ah,ah
	mov al, byte ptr [si]
	mov byte ptr [current_byte], al
	
	inc byte_count
	inc byte_adress
	inc si

	cmp si, di
	ja reload_buffer
	

	jmp get_byte_end
	
	reload_buffer:
	cmp input_file_end, 1
	je close_and_exit			;DAR NEPARASIAU UZDARYMO PROCEDUROS
	call bufferio_uzpildymas
	
		close_and_exit:
		call fclose
	
	get_byte_end:
	ret
ENDP get_byte
;*****************************************************************************************************
;gauna informacija apie baita
;*****************************************************************************************************
PROC gather_info

	mov al, byte ptr [current_byte]
	AND al, 11100111b ; maske
	cmp al, 00100110b ; ar tai prefixas?
	jne not_segment_prefix
	
segment_prefix:
	mov al, byte ptr [current_byte]
	mov byte ptr [prefix_byte], al
	mov byte ptr [prefix_used], 1
	call get_byte
	mov byte ptr [first_byte], al 
	jmp not_segment_prefix2
	
	not_segment_prefix:
	mov al, byte ptr [current_byte] ; grazinam baito reiksme po maskes
	not_segment_prefix2:	
	call get_format_number
	
	cmp byte ptr [format_nr],1d
	je formatnr1
	cmp byte ptr [format_nr],2d
	je formatnr2
	cmp byte ptr [format_nr],3d
	je formatnr3
	cmp byte ptr [format_nr],4d
	je formatnr4
	cmp byte ptr [format_nr],5d
	je formatnr5
;	cmp byte ptr [format_nr],6d
;	je formatnr6
;	cmp byte ptr [format_nr],7d
;	je formatnr7
;	cmp byte ptr [format_nr],8d
;	je formatnr8
;	cmp byte ptr [format_nr],9d
;	je formatnr9
;	cmp byte ptr [format_nr],10d
;	je formatnr10
;	cmp byte ptr [format_nr],11d
;	je formatnr11
;	cmp byte ptr [format_nr],12d
;	je formatnr12
;	cmp byte ptr [format_nr],13d
;	je formatnr13
;	cmp byte ptr [format_nr],14d
;	je formatnr14

jmp gather_info_end

formatnr1:
	call d_bito_apdorojimas
	call w_bito_apdorojimas
	call get_byte
	mov byte ptr [second_byte],al
	call mod_reg_rm_apdorojimas
	mov al, byte ptr [first_byte]
	call formatnr1_atpazinimas
	ret
	
formatnr2:
	call w_bito_apdorojimas
	call formatnr2_atpazinimas
	ret

formatnr3:
	call formatnr3_atpazinimas
	ret

formatnr4:
	call formatnr4_atpazinimas
	ret
	
formatnr5:
	call formatnr5_atpazinimas
	ret
	

	gather_info_end:
	ret
endp gather_info
;*****************************************************************************************************
;procedura gaut formato numeri
;*****************************************************************************************************
PROC get_format_number
	
	;op kodas d-bit w-bit  + adresacijos baitas + poslinkis
	cmp al, 03h	;gal cia ADD reg +=r/m?
	jb pirmas
	and al, 0FCh  ;uzmaskuojam d ir w bitus
	cmp al, 028h	;gal cia SUB reg -=r/m?
	je pirmas
	cmp al, 038h	; gal cia CMP reg ~ r/m?
	je pirmas
	cmp al, 088h	; gal cia MOV reg <> r/m?
	je pirmas
	cmp al, 020h	; gal cia AND reg <> r/m?
	je pirmas
	cmp al, 008h	; gal cia OR reg <> r/m?
	je pirmas
	jmp gal_antras
		
pirmas:
	mov byte ptr al, [current_byte]
	mov byte ptr [format_nr], 1d
	ret
	
gal_antras: ;operacijos kodas + w bitas bojb (bovb)	; nepamirsti apie mov akum!!!!!!!!!!!!!
	mov al, byte ptr [current_byte]
	and al, 0FEh
	cmp al, 04h	; gal cia ADD akum += bet. op?
	je antras
	cmp al, 2Ch	; gal cia SUB akum -= bet. op?
	je antras
	cmp al, 3Ch	;gal cia CMP akum ~ bet. op?
	je antras
	cmp al, 0Ch 	; gal cia or OR akum V bet. op?
	je antras
	cmp al, 24h	; gal cia AND akum & bet. op?
	je antras
	jmp gal_trecias
	
antras:
	mov byte ptr al, [current_byte]
	mov byte ptr [format_nr], 2d
	ret
	
gal_trecias:	; op.kodas, kuriame yra seg (push ir pop)
	mov al, byte ptr[current_byte]
	and al, 0E7h
	cmp al, 06h	; ar tai push seg reg?
	je trecias
	cmp al, 07h	; ar tai pop seg reg?
	je trecias
	jmp gal_ketvirtas
	
trecias:
	mov byte ptr al, [current_byte]
	mov byte ptr [format_nr], 3d
	ret
	
gal_ketvirtas:	; operacijos kodas + 3 reg bitai
	mov al, byte ptr[current_byte]
	and al, 0F8h
	cmp al, 40h		;INC, DEC, PUSH, POP
	jb gal_penktas
	cmp al, 50h
	ja gal_penktas
	
ketvirtas:
	mov byte ptr al, [current_byte]
	mov byte ptr[format_nr], 4d
	ret
	
gal_penktas:	; op kodas + poslinkis 1 baito
	mov al, byte ptr [current_byte]
	cmp al, 70h	;ar maziau nei visi salyginiai suoliai?
	jb gal_sestas
	cmp al, 0E2h ; gal tai loop + posl?
	je penktas
	cmp al, 0EBh	; ar tai vidinis artimas jmp?
	je penktas
	cmp al, 7Fh	;ar daugiau nei visi salyginiai suoliai?
	ja gal_sestas
	
penktas:
	mov byte ptr al, [current_byte]
	mov byte ptr [format_nr],5d 
	ret

gal_sestas:	; op kodas s-bitas w-bitas mod, pletinys, r/m  poslinkis  bojb [bovb] 
	mov al, byte ptr[current_byte]
	and al, 0FCh
	cmp al, 80h
	je sestas
	jmp gal_septintas
	
sestas:
	mov byte ptr al, [current_byte]
	mov byte ptr[format_nr],6d
	ret

gal_septintas:	; op kodas d0 mod 0sr r/m [poslinkis] bojb [bovb]
	mov al,byte ptr[current_byte]
	and al, 0FDh
	cmp al, 8Ch		; ar tai mov seg.reg<>r/m?
	jne gal_astuntas
	
septintas:
	mov byte ptr al, [current_byte]	
	mov byte ptr [format_nr],7d
	ret

gal_astuntas:	; ;op kodas w-bitas mod pletinys r/m [poslinkis]
	mov al,byte ptr[current_byte]
	and al, 0FEh
	cmp al, 0FEh
	je astuntas
	cmp al, 0F6h
	je astuntas
	jmp gal_devintas
	
astuntas:
	mov byte ptr al, [current_byte]
	mov byte ptr[format_nr],8d
	ret

gal_devintas:	;op kodas ajb avb srjb srvb
	mov al,byte ptr [current_byte]	
	cmp al, 0EAh	;ar tai isorinis tiesioginis jmp?
	je devintas
	cmp al, 9Ah	;ar tai tai isorinis tiesioginis call?
	je devintas
	jmp gal_desimtas
	
devintas:
	mov byte ptr al, [current_byte]
	mov byte ptr[format_nr],9d
	ret

gal_desimtas:	; op k w-bitas reg-bitai bojb [bovb]
	and al, 0F0h
	cmp al, 0B0h
	jne gal_vienuoliktas

desimtas:
	mov byte ptr al, [current_byte]
	mov byte ptr [format_nr],10d
	ret
	
gal_vienuoliktas:	; op k bojb bovb arba pjb pvb
	mov al, byte ptr [current_byte]
	cmp al, 0C3h	;gal tai ret?
	je vienuoliktas
	cmp al, 0CAh	; gal tai retf?
	je vienuoliktas
	cmp al, 0E8h	; gal tai call vidinis tiesioginis?
	je vienuoliktas
	cmp al, 0E9h	;gal tai jmp vidinis tiesioginis?
	je vienuoliktas
	jmp gal_dvyliktas
	
vienuoliktas:	
	mov byte ptr al, [current_byte]
	mov byte ptr [format_nr],11d
	ret

gal_dvyliktas:	; tiesiog op kodas (galimas int ir numeris)
	cmp al, 9Ch	; gal tai pushf?
	je dvyliktas	
	cmp al, 9Dh	;gal tai popf?
	je dvyliktas
	cmp al, 0CBh	
	jb gal_tryliktas	;retf, int 3, int num, into iret
	cmp al, 0CFh
	ja gal_tryliktas
	
dvyliktas:
	mov byte ptr al, [current_byte]
	mov byte ptr[format_nr],12d
	ret

gal_tryliktas:	;op kodas mod reg r/m [poslinkis]
	cmp al, 8Dh
	je tryliktas
	cmp al, 8Fh
	je tryliktas
	cmp al, 0FFh
	je tryliktas
	jmp gal_keturioliktas
	
tryliktas:
	mov byte ptr al, [current_byte]
	mov byte ptr[format_nr],13d
	ret

gal_keturioliktas:	; neatpazintas
	mov byte ptr al, [current_byte]
	mov byte ptr[format_nr],14d
	ret
	
endp get_format_number

;*****************************************************************************************************
; 1 formato apdorojimas
;*****************************************************************************************************
PROC d_bito_apdorojimas

	push ax
	and al, 02h
	shr al, 1
	mov byte ptr [d_bit],al
	pop ax
	ret
endp d_bito_apdorojimas
;*****************************************************************************************************
PROC w_bito_apdorojimas

	push ax
	and al, 01h
	mov byte ptr[w_bit],al
	pop ax
	ret
endp w_bito_apdorojimas
;*****************************************************************************************************
;mod reg r/m suzinojimo procedura
;*****************************************************************************************************	
PROC mod_reg_rm_apdorojimas
	push ax
	mov cl, 6
	and al, 0C0h
	shr al, cl
	mov byte ptr[ab_mod],al
	pop ax
	
	push ax
	mov cl, 3
	and al, 38h
	shr al, cl
	mov byte ptr[ab_reg],al
	pop ax
	
	push ax
	and al, 07h
	mov byte ptr[ab_rm],al
	pop ax
	
	ret
endp mod_reg_rm_apdorojimas
;*****************************************************************************************************
;1 formato atpazinimas op.k. d-bit w-bit mod reg r/m [poslinkis]
;*****************************************************************************************************
PROC formatnr1_atpazinimas
	and al, 0FCh
	
	cmp al, 00h		; gal cia add?
	je format1_add
	cmp al, 28h		;gal cia sub?
	je format1_sub
	cmp al, 38h		;gal cia cmp?
	je format1_cmp
	cmp al, 88h		;gal cia mov?
	je format1_mov
	cmp al, 08h
	je format1_or	;gal cia or?
	cmp al, 20h
	je format1_and	;gal cia and?
	
	
format1_add:
	call komanda_add
	jmp format1_d_bit
	
format1_sub:
	call komanda_sub
	jmp format1_d_bit
	
format1_cmp:
	call komanda_cmp
	jmp format1_d_bit
	
format1_mov:
	call komanda_mov
	jmp format1_d_bit
	
format1_and:
	call komanda_and
	jmp format1_d_bit
	
format1_or:
	call komanda_or
	jmp format1_d_bit
	
format1_d_bit:
	mov di, offset output_buffer
	add di, 25d
	cmp byte ptr [d_bit], 1
	jne format1_dest0
	
	format1_dest1:
	call reg_lauko_rasymas
	call Idek_kableli
	call rmo_lauko_rasymas
	call baitu_irasymas
	ret
	
	format1_dest0:
	call rmo_lauko_rasymas
	call Idek_kableli
	call reg_lauko_rasymas
	call baitu_irasymas
	
ret

endp formatnr1_atpazinimas
;*****************************************************************************************************
;2 formato atpazinimas. op.k. w-bit bojb [bovb]
;*****************************************************************************************************
PROC formatnr2_atpazinimas
	and al, 0FEh
	cmp al, 04h	; gal cia ADD akum += bet. op?
	je format2_add
	cmp al, 2Ch	; gal cia SUB akum -= bet. op?
	je format2_sub
	cmp al, 3Ch	;gal cia CMP akum ~ bet. op?
	je format2_cmp
	cmp al, 0Ch
	je format2_or ;gal cia OR akum V bet. op?
	cmp al, 24h
	je format2_and	;gal cia AND akum & bet. op?
	
	format2_add:
	call komanda_add
	jmp format2_w
	
	format2_sub:
	call komanda_sub
	jmp format2_w
	
	format2_cmp:
	call komanda_cmp
	jmp format2_w
	
	format2_and:
	call komanda_and
	jmp format2_w
	
	format2_or:
	call komanda_or
	jmp format2_w
	
format2_w:
	mov di, offset output_buffer
	add di, 25d
	mov byte ptr ds:[di], 'a'
	inc di
	cmp byte ptr[w_bit],1
	je format2_w1
	
format2_w0:	
	mov byte ptr ds:[di], 'l'
	inc di
	call Idek_kableli
	call get_byte
	mov byte ptr[second_byte], al 
	
	call baito_vertimas
	mov byte ptr ds:[di],'h'
	inc di
	
	call baitu_irasymas

	ret
	
format2_w1:
	mov byte ptr ds:[di], 'x'
	inc di
	call Idek_kableli
	call get_byte
	mov byte ptr[second_byte],al
	call get_byte
	mov byte ptr[third_byte],al
	call baito_vertimas
	mov al, byte ptr[second_byte]
	call baito_vertimas
	mov byte ptr ds:[di],'h'
	inc di
	
	call baitu_irasymas
	ret
	
;*********************************
endp formatnr2_atpazinimas
;*****************************************************************************************************
;3 formato atpazinimas push sreg pop sreg
;*****************************************************************************************************
PROC formatnr3_atpazinimas
	push ax
	and al, 01h
	cmp al, 01h
	je format3_pop
	jmp format3_push
	
format3_pop:
	call komanda_pop
	jmp format3_segmentas
format3_push:
	call komanda_push

format3_segmentas:
	pop ax
	mov di, offset output_buffer
	add di, 25d
	call segment_prefix_recognition
	mov byte ptr ds:[di],dh
	mov byte ptr ds:[di+1],dl
	add di, 2 
	call baitu_irasymas
	ret
	
endp formatnr3_atpazinimas
;*****************************************************************************************************
; 4 formato atpazinimas op.k. ir 3 reg bitai (zodinio registro)
PROC formatnr4_atpazinimas
	push ax
	and al, 0F8h
	cmp al, 40h	;gal tai inc?
	je format4_inc
	cmp al, 48h	;gal tai dec?
	je format4_dec
	cmp al, 50h	;gal tai push?
	je format4_push
	cmp al, 58h	;gal tai pop?
	je format4_pop
	
format4_inc:
	call komanda_inc
	jmp format4_reg
	
format4_dec:
	call komanda_dec
	jmp format4_reg
	
format4_push:
	call komanda_call
	jmp format4_reg
	
format4_pop:
	call komanda_pop
	
format4_reg:
	pop ax
	and al, 07h
	mov di, offset output_buffer
	add di, 25d
	
	call regw1_apdorojimas
	mov byte ptr ds:[di], dh
	mov byte ptr ds:[di+1], dl
	add di, 2
	
	call baitu_irasymas
	ret
	
endp formatnr4_atpazinimas
;*****************************************************************************************************
;5 formato atpazinimas, op kodas ir poslinkis 5 baitu
PROC formatnr5_atpazinimas

	
	mov di, offset output_buffer
	add di, 20d
	
	cmp al, 0E2h	; gal tai loop?
	je format5_loop
	cmp al, 0EBh
	je format5_jmp	; o gal vidinis artimas jmp?
;atpazystam salygini suoli	
	and ax, 0Fh
	mov byte ptr ds:[di],'j'
	inc di
	test al, 0001b
	jne format5_N
format5_toliau:
	test al, 0010b
	jne format5_AE_BE_LE_P

	
format5_N:
	mov byte ptr ds:[di],'n'
	inc di
	jmp format5_toliau

format5_AE_BE_LE_P:
	test al, 0100b
	jne format5_BE_LE
	test al, 1000b
	jne format5_P
	mov byte ptr ds:[di], 'a'
	mov byte ptr ds:[di+1], 'e'
	jmp format5_atpazinta
	
format5_BE_LE:
	test al, 1000b
	jne format5_LE
	mov byte ptr ds:[di], 'b'
	mov byte ptr ds:[di+1], 'e'
	jmp format5_atpazinta
	
format5_LE:
	mov byte ptr ds:[di], 'l'
	mov byte ptr ds:[di+1], 'e'
	jmp format5_atpazinta

format5_P:
	mov byte ptr ds:[di], 'p'
	jmp format5_atpazinta
	
format5_loop:
	mov byte ptr ds:[di], 'l'
	mov byte ptr ds:[di+1], 'o'
	mov byte ptr ds:[di+2], 'o'
	mov byte ptr ds:[di+3], 'p'
	jmp format5_atpazinta
	
format5_jmp:
	call komanda_jmp
	
format5_atpazinta:
	call get_byte
	mov byte ptr [second_byte], al
	call zenklo_pletimas
	mov al, dh
	call baito_vertimas
	mov al, dl
	call baito_vertimas
	call baitu_irasymas
	
	ret
	
endp formatnr5_atpazinimas
;*****************************************************************************************************
;baitas imamas is al registro. paruosimas ir idejimas i buferi adresu di
;*****************************************************************************************************
PROC baito_vertimas
	push bx
	push cx
	
		push ax
		and al, 00001111b
		cmp al, 9d
		ja hex_raidyte
		mov dl,al
		add dl, 30h
		jmp antras_hex
		
	hex_raidyte:
		mov dl,al
		add dl, 55d
		
antras_hex:
	pop ax
	and al, 11110000b
	mov cl, 4
	shr al, cl
	cmp al, 9d
	ja hex_raidyte_2
	mov dh,al
	add dh, 30h
	jmp baito_vertimas_pabaiga
	
hex_raidyte_2:
	mov dh, al
	add dh, 55d

baito_vertimas_pabaiga:
	mov byte ptr ds:[di],dh
	mov byte ptr ds:[di+1],dl
	pop cx
	pop bx
ret
ENDP baito_vertimas
;*****************************************************************************************************
;komandos baitu rasymas i buferi
;*****************************************************************************************************
PROC baitu_irasymas
	mov di, offset output_buffer
	add di, 6
	xor ch,ch
	mov cl, byte ptr[byte_count]
	
	cmp prefix_used, 1
	je nuo_prefixo
	
uz_prefixo:
	mov bx, 1 
	
cikliukas:
	mov al, byte ptr [bx+prefix_byte]
	inc bx
	call baito_vertimas
	loop cikliukas
	
	ret 
	
;******************
nuo_prefixo:
	xor bx,bx
	jmp uz_prefixo
endp baitu_irasymas
;*****************************************************************************************************
;prefixo atpazinimo procedura, patalpina i dx
;*****************************************************************************************************
PROC segment_prefix_recognition
	push ax
	AND al, 00011000b
	mov cl, 3
	shr al,cl
	
	cmp al,0b
	jne maybe_cseg
	mov dh, 'e'
	mov dl, 's'
	jmp segment_prefix_end
	
maybe_cseg:
	cmp al,1b
	jne maybe_sseg
	mov dh, 'c'
	mov dl, 's'
	jmp segment_prefix_end
	
maybe_sseg:
	cmp al, 10b
	jne maybe_dseg
	mov dh, 's'
	mov dl, 's'
	jmp segment_prefix_end
	
maybe_dseg: ;jeigu ne visi kiti segmentai, reiskia tik ds
	mov dh, 'd'
	mov dl, 's'

segment_prefix_end:
	pop ax
	ret
ENDP segment_prefix_recognition
;*****************************************************************************************************

PROC rmo_lauko_rasymas
	
	
	cmp [w_bit],1
	je word_bit_1
	
	cmp [ab_mod],11b
	je mod_bits_11_w0_tarpinis
	
	call papild_byte_ptr
word_bit_1_after:

	cmp prefix_used, 1
	jne no_prefix_used
	mov al, byte ptr[prefix_byte]
	call segment_prefix_recognition
	mov byte ptr ds:[di], dh
	mov byte ptr ds:[di+1], dl
	mov byte ptr ds:[di+2], ':'
	add di, 3
	
no_prefix_used:
	mov byte ptr ds:[di], '['
	inc di
	

	mov al, byte ptr [ab_rm]
	cmp al, 110b
	je gal_ties_adr
ne_tiesioginis:
	call rm_apdorojimas
	cmp byte ptr[ab_mod],0b
	je po_poslinkio
	cmp byte ptr[ab_mod], 1b
	je mod_bits_01
	
;*******************
mod_bits_11_w0_tarpinis:
	jmp mod_bits_11_w0
;***** *************
word_bit_1:

	cmp byte ptr [ab_mod],11b
	je mod_bits_11_w1
	
	call papild_word_ptr
	jmp word_bit_1_after
;*******************
gal_ties_adr:
	cmp byte ptr [ab_mod], 0b
	je tiesioginis
	jmp ne_tiesioginis
;*******************
mod_bits_01:
	call get_byte
	mov byte ptr [third_byte],al
	call zenklo_pletimas
	mov al, dh
	call baito_vertimas
	mov al, dl
	call baito_vertimas
	jmp po_poslinkio
;*******************
mod_bits_10:
tiesioginis:
	call get_byte
	mov byte ptr [third_byte],al
	call get_byte
	mov byte ptr [fourth_byte],al
	call baito_vertimas
	mov al, byte ptr [third_byte]
	call baito_vertimas


mod_bits_11_w1:
	mov al, byte ptr [ab_rm]
	call regw1_apdorojimas
	mov byte ptr ds:[di],dh
	mov byte ptr ds:[di],dl
	add di, 2
		
	ret
mod_bits_11_w0:
	mov al, byte ptr[ab_rm]
	call regw0_apdorojimas
	mov byte ptr ds:[di],dh
	mov byte ptr ds:[di],dl
	add di, 2
	
	ret	
po_poslinkio:
	mov byte ptr ds:[di], ']'
	inc di 
	
	ret

endp rmo_lauko_rasymas

;*****************************************************************************************************	
;reg lauko rasymas
;*****************************************************************************************************
PROC reg_lauko_rasymas
	cmp byte ptr[w_bit], 1
	je w_bit_1
	call regw0_apdorojimas
	
ret
	
w_bit_1:
	call regw0_apdorojimas
ret
endp reg_lauko_rasymas

;*****************************************************************************************************
; pletimas pagal zenkla, tikrinamas al bitas, imeta reiksme i dx'a
;*****************************************************************************************************
PROC zenklo_pletimas
	cmp al, 80h
	jb plesti_nereikia
	mov dh, 0FFh
	mov dl, al
	ret
	
plesti_nereikia:
	mov dh, 00h
	mov dl, al
	ret

endp zenklo_pletimas
;*****************************************************************************************************

PROC fprintf
		mov bx, output_file_handle
		mov ah,40h
		mov cx, 30h
		mov dx, offset output_buffer
		int 21h
	ret
endp fprintf
;kodo pradzia
;*****************************************************************************************************
Gyvenimas:

	mov ax, @data
	mov ds, ax
	
	call paleidimo_parametrai
	call failu_apdorojimas_darbui
	call bufferio_uzpildymas
main_cycle:
		call output_bufferio_paruosimas
		call get_byte
		mov byte ptr [first_byte], al
		call gather_info
		call fprintf
		call zero_parameters
	jmp main_cycle
		
	call exit_program
	END Gyvenimas
	