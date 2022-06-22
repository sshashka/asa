STSEG SEGMENT PARA STACK "STACK" ;опис сегмента стека
DB 64 DUP ( "STACK" )
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA" ;опис сегмента даних
outputx db "Enter x:", 10, "$"
outputy db "Enter y:", 10, "$"
Yourx db "Your x:", 0, "$"
Youry db "      Your y:", 0, "$"
outputres1 db "      For x>0 && y>0 => (x+y)/(xy)", 10, "$"
outputres2 db "      For x<0 && y<0 => 25y", 10, "$"
outputres3 db "      For x>10 && y=0 => 6x", 10, "$"
outputres4 db "      For else => 1", 10, "$"
outputres0 db "." ,0, "$"
dump db 4, ?, 4 dup('?'), "$" ;обмеження вводу 3х символів
numx dw 0
numy dw 0
num1 dw 0
num2 dw 0
numres dw 1
signed db 0
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE" ;опис сегмента коду

MAIN PROC FAR ;код основної ф-ції
ASSUME CS: CSEG, DS: DSEG, SS: STSEG
; адреса повернення
PUSH DS
MOV AX, 0 
PUSH AX
; ініціалізація DS
MOV AX, DSEG
MOV DS, AX

;-------------ВВЕДЕННЯ Х-------------
lea dx, outputx; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS

lea dx, dump  ; починається зчитування даних з консолі 
mov ah, 10 ;процедура 10 0Аh для введення рядка символів
int 21h ;переривання DOS

lea BX, dump+2 ;загружає в регістр вх лічильник+2
mov DX, 0 ; тимчасовий результат
mov CL, dump + 1; лічильник

CMP dump+2, "-"     ; Поки dump+2 від'ємне– виконувати
JE  hasminus
jmp l1 ;повторення циклу
hasminus:
mov signed, 1
sub CL, 1 ;вычитает из первого операнда второй //с1 = с1-1
add BX, 1 ;складывает операнды вх = вх+1

l1: ;початок циклу, к-ть повторень
mov AX, DX
mov CH, 10 
mul CH ; множення поточного значення на 10
mov DX, AX ; and store it in DX
mov AH, 0
mov AL, [BX] 
sub AL, "0" ;вычитает из первого операнда второй
add DX, AX ; складывает операнды и записывает их сумму на место первого операнда
inc BX ;увеличивает на 1 свой операнд (ВХ)
mov CH, 0
loop l1 ;позволяет организовать цикл
; now in DX we have module of input

mov numx, dx

cmp signed, 0
je enty
mov AX, DX
sub DX, AX
sub DX, AX
mov numx, dx



;-------------ВВЕДЕННЯ Y-------------
enty:
lea dx, outputy; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS

lea dx, dump  ; починається зчитування даних з консолі 
mov ah, 10 ;процедура 10 0Аh для введення рядка символів
int 21h ;переривання DOS

lea BX, dump+2 ;загружає в регістр вх лічильник+2
mov DX, 0 ; тимчасовий результат
mov CL, dump + 1; лічильник

CMP dump+2, "-"     ; Поки dump+2 від'ємне– виконувати
JE  hasminusy
jmp ly1 ;повторення циклу
hasminusy:
mov signed, 1
sub CL, 1 ;вычитает из первого операнда второй //с1 = с1-1
add BX, 1 ;складывает операнды вх = вх+1

ly1: ;початок циклу, к-ть повторень
mov AX, DX
mov CH, 10 
mul CH ; множення поточного значення на 10
mov DX, AX ; and store it in DX
mov AH, 0
mov AL, [BX] 
sub AL, "0" ;вычитает из первого операнда второй
add DX, AX ; складывает операнды и записывает их сумму на место первого операнда
inc BX ;увеличивает на 1 свой операнд (ВХ)
mov CH, 0
loop ly1 ;позволяет организовать цикл
; now in DX we have module of input

mov numy, dx

cmp signed, 0
je b1
mov AX, DX
sub DX, AX
sub DX, AX
mov numy, dx

;-------------УМОВНИЙ ПЕРЕХІД X>0 && Y>0-------------
b1:
lea dx, Yourx ; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS
mov dx, numx
mov numres, dx
call digit

lea dx, Youry ; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS
mov dx, numy
mov numres, dx
call digit

cmp numx,0
JG a1
jmp b2
ret

a1:
cmp numy,0
JG a2
jmp b2
ret

a2:
sub DX, 32 ;виконання додавання дх+32
mov dx, numx
mov ax, dx
mov dx, numy
imul  dx
mov num1,ax ;num1 = xy

mov dx, numy
mov num2, dx ;num2 = numy
mov dx, numx
add num2, dx ;num2 = x+y

mov dx, num2
mov ax, dx
mov dx, num1
mov bx, dx
cwd
idiv bx
mov num1, ax ;ціле
mov num2, dx ;остача
mov dx, num1
mov numres, dx

lea dx, outputres1 ; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS

call digit

lea dx, outputres0 ; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS

mov dx, num2
mov numres, dx

call digit

RET

;-------------УМОВНИЙ ПЕРЕХІД X<0 && Y<0-------------
b2:
cmp numx,0
JL a3
jmp b3
ret

a3:
cmp numy,0
JL a4
jmp b3
ret

a4:
mov ax, 25
mov dx, numy
imul  dx
mov numres, ax
lea dx, outputres2 ; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS
call digit ;Вызов процедуры digit
ret

;-------------УМОВНИЙ ПЕРЕХІД X>10 && Y=0-------------
b3:
cmp numx,10
JG a5
jmp b4
call digit ;Вызов процедуры digit
ret

a5:
cmp numy,0
JE a6
jmp b4
ret

a6:
mov ax, 6
mov dx, numx
imul dx
mov numres, ax
lea dx, outputres3 ; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS
call digit ;Вызов процедуры digit
ret

;-------------УМОВНИЙ ПЕРЕХІД ELSE-------------
b4:
mov numres, 1
lea dx, outputres4 ; виведення рядка даних output 
mov ah,9 ;процедура 9 для виведення рядка
int 21h ;Прерывание DOS
call digit ;Вызов процедуры digit
ret

MAIN ENDP ;ознака кінця програми
;-----------------------------------------------

digit proc ;процедура для виведення цілого числа
mov bx, numres ;num записується до регістру  bx
or bx, bx
jns m1 ;перевіряється знак числа
mov al, '-' ;для від'ємного здійснюються відповідні перетворення
int 29h
neg bx
m1: ;число записується до акумулятора для послідовного ділення на 10
mov ax, bx
xor cx, cx ;регістр сх використовується як лічильник к-ті розрядів числа
mov bx, 10
m2: 
xor dx, dx
div bx ;число ділиться на 10
add dl, '0' ;до остачі додається код символу 0
push dx
inc cx ;код символу цифри записується до стеку
test ax, ax
jnz m2 ;повторюється поки ціла частина від ділення числа на 10 не стане дорівнювати 0
m3: ;здійснюється вивід символів-цифр числа, починаючи зі старшого розряду
pop ax
int 29h
loop m3
;jmp exit
ret ;возврат из ближней процедуры
digit endp ;переривання процедури

exit:
mov ah, 4ch
int 21h ;Прерывание DOS
ret

CSEG ENDS ;ознака кінця сегменту коду
END MAIN  ;ознака кінця програми