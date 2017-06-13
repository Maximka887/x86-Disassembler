PROC komanda_add
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'a'
	mov byte ptr ds:[di+1], 'd'
	mov byte ptr ds:[di+2], 'd'
	add di, 3
ret
ENDP komanda_add
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_sub
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 's'
	mov byte ptr ds:[di+1], 'u'
	mov byte ptr ds:[di+2], 'b'
	add di, 3
ret
ENDP komanda_sub
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_cmp
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'c'
	mov byte ptr ds:[di+1], 'm'
	mov byte ptr ds:[di+2], 'p'
	add di, 3 
ret
ENDP komanda_cmp
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_mov
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'm'
	mov byte ptr ds:[di+1], 'o'
	mov byte ptr ds:[di+2], 'v'
	add di, 3
ret
ENDP komanda_mov
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_push
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'p'
	mov byte ptr ds:[di+1], 'u'
	mov byte ptr ds:[di+2], 's'
	mov byte ptr ds:[di+3], 'h'
	add di, 4
ret
ENDP komanda_push
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_pop
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'p'
	mov byte ptr ds:[di+1], 'o'
	mov byte ptr ds:[di+2], 'p'
	add di, 3
ret
ENDP komanda_pop
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_dec
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'd'
	mov byte ptr ds:[di+1], 'e'
	mov byte ptr ds:[di+2], 'c'
	add di, 3
ret
ENDP komanda_dec
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_inc
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'i'
	mov byte ptr ds:[di+1], 'n'
	mov byte ptr ds:[di+2], 'c'
	add di, 3
ret
ENDP komanda_inc
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_call
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'c'
	mov byte ptr ds:[di+1], 'a'
	mov byte ptr ds:[di+2], 'l'
	mov byte ptr ds:[di+3], 'l'
	add di, 4 
ret
ENDP komanda_call
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_ret
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'r'
	mov byte ptr ds:[di+1], 'e'
	mov byte ptr ds:[di+2], 't'
	add di, 3
ret
ENDP komanda_ret
;*****************************************************************************************************
;*****************************************************************************************************
PROC komanda_jmp
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'j'
	mov byte ptr ds:[di+1], 'm'
	mov byte ptr ds:[di+2], 'p'
	add di, 3d
ret
ENDP komanda_jmp
;*****************************************************************************************************
PROC komanda_and
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'a'
	mov byte ptr ds:[di+1], 'n'
	mov byte ptr ds:[di+2], 'd'
	add di, 3
ret
ENDP komanda_and
;*****************************************************************************************************
PROC komanda_or
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'o'
	mov byte ptr ds:[di+1], 'r'
	add di, 2
ret
ENDP komanda_or
;*****************************************************************************************************
PROC komanda_xor
	mov di, offset output_buffer
	add di, 20d
	
	mov byte ptr ds:[di], 'x'
	mov byte ptr ds:[di+1], 'o'
	mov byte ptr ds:[di+2], 'r'
	add di, 3 
ret
ENDP komanda_xor
;*****************************************************************************************************

PROC papild_word_ptr
	
	mov byte ptr ds:[di], 'w'
	mov byte ptr ds:[di+1], 'o'
	mov byte ptr ds:[di+2], 'r'
	mov byte ptr ds:[di+3], 'd'
	mov byte ptr ds:[di+4], ' '
	mov byte ptr ds:[di+5], 'p'
	mov byte ptr ds:[di+6], 't'
	mov byte ptr ds:[di+7], 'r'
	mov byte ptr ds:[di+8], ' '
	add di, 8
ret
ENDP papild_word_ptr
;*****************************************************************************************************
PROC papild_byte_ptr
	
	mov byte ptr ds:[di], 'b'
	mov byte ptr ds:[di+1], 'y'
	mov byte ptr ds:[di+2], 't'
	mov byte ptr ds:[di+3], 'e'
	mov byte ptr ds:[di+4], ' '
	mov byte ptr ds:[di+5], 'p'
	mov byte ptr ds:[di+6], 't'
	mov byte ptr ds:[di+7], 'r'
	mov byte ptr ds:[di+8], ' '
	add di, 9
ret
ENDP papild_byte_ptr
;*****************************************************************************************************

PROC Idek_registra

	mov byte ptr ds:[di],dh
	mov byte ptr ds:[di+1],dl
	add di, 2d	
ret
ENDP Idek_registra
;*****************************************************************************************************

PROC Idek_kableli

	mov byte ptr ds:[di], ','
	mov byte ptr ds:[di+1], ' '
	add di, 2d	
ret
ENDP Idek_kableli
;*****************************************************************************************************

PROC Idek_skliaustus_w0
	
	mov byte ptr ds:[di], '['
	inc di
	mov byte ptr ds:[di+2], ']'
ret
endp Idek_skliaustus_w0
;*****************************************************************************************************

PROC Idek_skliaustus_w1
	
	mov byte ptr ds:[di], '['
	inc di
	mov byte ptr ds:[di+4], ']'
ret
endp Idek_skliaustus_w1
;*****************************************************************************************************





;*****************************************************************************************************
; atpazina registra ir patalpina ji i dx
;*****************************************************************************************************
PROC regw0_apdorojimas
		
		test al, 100b
		je reg_w0_0xx
		jmp reg_w0_1xx
		
		reg_w0_0xx:
		test al, 10b
		je reg_w0_00x
		jmp reg_w0_01x
		
		reg_w0_1xx:
		test al, 10b
		je reg_w0_10x
		jmp reg_w0_11x
		
			reg_w0_00x:
			test al, 1b
			je reg_w0_000
			jmp reg_w0_001
			
			reg_w0_01x:
			test al, 1b
			je reg_w0_010
			jmp reg_w0_011
			
			reg_w0_10x:
			test al, 1b
			je reg_w0_100
			jmp reg_w0_101
			
			reg_w0_11x:
			test al, 1b
			je reg_w0_110
			jmp reg_w0_111
			
				reg_w0_000:
				mov dh, 'a'
				mov dl, 'l'
				jmp regw0_pabaiga
				
				reg_w0_001:
				mov dh, 'c'
				mov dl, 'l'
				jmp regw0_pabaiga
				
				reg_w0_010:
				mov dh, 'd'
				mov dl, 'l'
				jmp regw0_pabaiga
				
				reg_w0_011:
				mov dh, 'b'
				mov dl, 'l'
				jmp regw0_pabaiga
				
				reg_w0_100:
				mov dh, 'a'
				mov dl, 'h'
				jmp regw0_pabaiga
				
				reg_w0_101:
				mov dh, 'c'
				mov dl, 'h'
				jmp regw0_pabaiga
				
				reg_w0_110:
				mov dh, 'd'
				mov dl, 'h'
				jmp regw0_pabaiga
				
				reg_w0_111:
				mov dh, 'b'
				mov dl, 'h'
				jmp regw0_pabaiga
				
	regw0_pabaiga:
	ret
endp regw0_apdorojimas
;*****************************************************************************************************

;atpazina registra ir patalpina ji i dx
;*****************************************************************************************************
PROC regw1_apdorojimas
		
		test al, 100b
		je reg_w1_0xx
		jmp reg_w1_1xx
		
		reg_w1_0xx:
		test al, 10b
		je reg_w1_00x
		jmp reg_w1_01x
		
		reg_w1_1xx:
		test al, 10b
		je reg_w1_10x
		jmp reg_w1_11x
		
			reg_w1_00x:
			test al, 1b
			je reg_w1_000
			jmp reg_w1_001
			
			reg_w1_01x:
			test al, 1b
			je reg_w1_010
			jmp reg_w1_011
			
			reg_w1_10x:
			test al, 1b
			je reg_w1_100
			jmp reg_w1_101
			
			reg_w1_11x:
			test al, 1b
			je reg_w1_110
			jmp reg_w1_111
			
				reg_w1_000:
				mov dh, 'a'
				mov dl, 'x'
				jmp regw1_pabaiga
				
				reg_w1_001:
				mov dh, 'c'
				mov dl, 'x'
				jmp regw1_pabaiga
				
				reg_w1_010:
				mov dh, 'd'
				mov dl, 'x'
				jmp regw1_pabaiga
				
				reg_w1_011:
				mov dh, 'b'
				mov dl, 'x'
				jmp regw1_pabaiga
				
				reg_w1_100:
				mov dh, 's'
				mov dl, 'p'
				jmp regw1_pabaiga
				
				reg_w1_101:
				mov dh, 'b'
				mov dl, 'p'
				jmp regw1_pabaiga
				
				reg_w1_110:
				mov dh, 's'
				mov dl, 'i'
				jmp regw1_pabaiga
				
				reg_w1_111:
				mov dh, 'd'
				mov dl, 'i'
				jmp regw1_pabaiga
				
	regw1_pabaiga:
	ret
endp regw1_apdorojimas
;*****************************************************************************************************


;poslinkio suzinojimas
;*****************************************************************************************************

PROC rm_apdorojimas
			
		test al, 100b
		je rm_0xx
		jmp rm_1xx
		
		rm_0xx:
		test al, 10b
		je rm_00x
		jmp rm_01x
		
		rm_1xx:
		test al, 10b
		je rm_10x
		jmp rm_11x
		
			rm_00x:
			test al, 1b
			je rm_000
			jmp rm_001
			
			rm_01x:
			test al, 1b
			je rm_010
			jmp rm_011
			
			rm_10x:
			test al, 1b
			je rm_100
			jmp rm_101
			
			rm_11x:
			test al, 1b
			je rm_110_tarp
			jmp rm_111
			
				rm_000:
				mov byte ptr ds:[di],'b'
				mov byte ptr ds:[di+1],'x'
				mov byte ptr ds:[di+2],'+'
				mov byte ptr ds:[di+3],'s'
				mov byte ptr ds:[di+4],'i'
				add di, 5
				jmp rm_pabaiga
				
				rm_001:
				mov byte ptr ds:[di],'b'
				mov byte ptr ds:[di+1],'x'
				mov byte ptr ds:[di+2],'+'
				mov byte ptr ds:[di+3],'d'
				mov byte ptr ds:[di+4],'i'
				add di, 5
				jmp rm_pabaiga
				
				rm_010:
				mov byte ptr ds:[di],'b'
				mov byte ptr ds:[di+1],'p'
				mov byte ptr ds:[di+2],'+'
				mov byte ptr ds:[di+3],'s'
				mov byte ptr ds:[di+4],'i'
				add di, 5
				jmp rm_pabaiga
				
				rm_011:
				mov byte ptr ds:[di],'b'
				mov byte ptr ds:[di+1],'p'
				mov byte ptr ds:[di+2],'+'
				mov byte ptr ds:[di+3],'d'
				mov byte ptr ds:[di+4],'i'
				add di, 5
				jmp rm_pabaiga
				
				rm_110_tarp: ;issisuku is tolimo suolio 
				jmp rm_110
				
				rm_100:
				mov byte ptr ds:[di],'s'
				mov byte ptr ds:[di+1],'i'
				add di, 2
				jmp rm_pabaiga
				
				rm_101:
				mov byte ptr ds:[di],'d'
				mov byte ptr ds:[di+1],'i'
				add di, 2
				jmp rm_pabaiga
				
				rm_110:
				mov byte ptr ds:[di],'b'
				mov byte ptr ds:[di+1], 'p'
				add di, 2 
				jmp rm_pabaiga
				
				rm_111:
				mov byte ptr ds:[di],'b'
				mov byte ptr ds:[di+1],'x'
				add di, 2
				jmp rm_pabaiga
				
	rm_pabaiga:
	ret
endp rm_apdorojimas
;*****************************************************************************************************

