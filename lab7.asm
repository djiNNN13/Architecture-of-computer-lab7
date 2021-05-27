IDEAL
MODEL small
STACK 2048
 ;					ІІ. Макроси
MACRO M_init		; Макрос для ініціалізації. Його початок
	mov ax, @data	; @data ідентифікатор, що створюються директивою MODEL
	mov ds, ax		; Завантаження початку сегменту даних в регістр DS
	mov es, ax		; Завантаження початку сегменту даних в регістр ES
	ENDM M_init		; Кінець макросу
;					ІІІ. Початок сегменту даних
DATASEG
startmsg db "--------Team 2--------",13,10,'$'
message1 db "Commands:", 13, 10, '$'
message2 db "r - calculate expression", 13, 10, '$'
message3 db "T - play sound", 13, 10, '$'
message4 db "y - exit program", 13, 10, '$'
exitmsg db "---------Bye----------",13,10,'$'

a1 db -7
a2 db 3
a3 db 2
a4 db 4
a5 db 2

MSECONDS EQU 2000
FREQ EQU 600
PORT_B EQU 61H
COMMAND_REG EQU 43H ; Адреса командного регістру
CHANNEL_2 EQU 42H ; Адреса каналу 2

CODESEG
Start:
   M_init
   mov al,1
   out 42h, al
   call MainMenu
   Main:
      mov ah, 08h
      int 21h
      call MainMenu

      cmp al, "r" ; r=72h 
      je Count
      cmp al, "T" ; T=54h
      je Beep
      cmp al, "y" ;y=79h
      je Exit
      jmp Main
;-------------FUNCTION COUNT----------------
   Count:
      call Calculate
      jmp Main
;---------------FUNCTION SOUND------------------
   Beep:
      call Sound
      jmp Main
;---------------FUNCTION EXIT------------------
   Exit:
      mov dx, offset exitmsg
      call DisplayText
      mov ah,4ch
      mov al, 0
      int 21h
;------------PROCEDURE MAIN MENU------------------
   PROC MainMenu
      push ax
      push dx
      ; Очищаємо консоль
	   mov ax,03h
	   int 10h
	   ; Виводимо текст у консоль
	   mov ah, 09h
	   mov dx, offset startmsg
      call DisplayText
      mov dx, offset message1
      call DisplayText
      mov dx, offset message2
      call DisplayText
      mov dx, offset message3
      call DisplayText
      mov dx, offset message4
      call DisplayText
	   pop dx
	   pop ax
	   ret 
   ENDP MainMenu
;-------------PROCEDURE DISPLAY TEXT---------------------
   PROC DisplayText
      mov ah,9
      int 21h
      xor dx, dx
      ret
   ENDP DisplayText
;-----------PROCEDURE CALCULATE-------------------
   PROC Calculate
		xor ax,ax
		mov al, [a1]
		mov dl, [a2]

		call Sum

		imul [a3]

		idiv [a4]

		mov dl, [a5]
		call Sum

		; Перевіряємо, чи від'ємний наш результат
		cmp al, 0
		add al, 30h
		; Виводимо число у консоль
		mov dl, al
		mov ah, 02h
		int 21h

		ret
		ENDP Calculate
;-------------PROCEDURE SUM---------------------
	PROC Sum
		; Перевіряємо знак першого доданку
		cmp al, 0
		js minus
		jmp plus
		; Перевіряємо знак другого доданку, якщо перший додатній
		plus:
		cmp dl, 0
		js plus_minus
		jmp plus_plus
		; Перевіряємо знак другого доданку, якщо перший від'ємний
		minus:
		cmp dl, 0
		js minus_minus
		jmp minus_plus_2

			plus_plus:
			add al, dl
			jmp endPoint

			plus_minus:
			neg dl
			sub al, dl
			jmp endPoint

			minus_plus_2:
			neg al
			sub dl, al
			mov al, dl
			jmp endPoint

			minus_minus:
			neg al
			neg dl
			add al, dl
			neg al
			jmp endPoint

		endPoint:
		   ret
		ENDP Sum
;-------------PROCEDURE SOUND---------------------
PROC Sound
 ;--- дозвіл каналу 2 встановлення порту В мікросхеми 8255
 in al,PORT_B ;Читання
 OR al,3 ;Встановлення двох молодших бітів
 out PORT_B,al ;пересилка байта в порт B мікросхеми 8255

 ;--- встановлення регістрів порту вводу-виводу
 mov AL,10110110B ;біти для каналу 2
 out COMMAND_REG,al ;байт в порт командний регістр

 ;--- встановлення лічильника
 mov ax,1190000/FREQ ;Встановлення частоти звуку
 out CHANNEL_2,AL ;відправка AL
 mov al,ah ;відправка старшого байту в AL
 out CHANNEL_2,al ;відправка старшого байту

 call Timer
 ;--- виключення звуку
 in al,PORT_B ;отримуємо байт з порту В
 and al,11111100B ;скидання двох молодших бітів
 out PORT_B,al ;пересилка байтів в зворотному напрямку
 ret
 ENDP Sound

;-----------PROCEDURE TIMER-------------------
PROC Timer
push cx
mov cx, MSECONDS
loop1:                 
  push cx               
  mov  cx,  MSECONDS
  loop2:
     loop loop2
  pop  cx
  loop loop1
pop cx
ret
ENDP Timer

END Start