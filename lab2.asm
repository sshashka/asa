STSEG SEGMENT PARA STACK "STACK" ;опис сегмента стека
DB 64 DUP ( "STACK" )
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA" ;опис сегмента даних
output db "Enter value:", 10, "$"
dump db 4, ?, 4 dup('?'), "$" ;обмеження вводу 3х символів
num dw 0
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

lea dx, output ; виведення рядка даних output 
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

cmp signed, 0 ;команда сравнения signed и 0
je represent ; Если равно, ...
mov AX, DX
sub DX, AX
sub DX, AX

represent:
sub DX, 32 ;виконання додавання дх+32

mov num, DX ; num = DX 

MOV dl, 10 ;Позиция X
MOV ah, 02h ;Номер функции позиционирование курсора
INT 21h ;Прерывание DOS

call digit ;Вызов процедуры digit 

RET ;возврат из ближней процедуры
MAIN ENDP ;ознака кінця програми

;-----------------------------------------------

digit proc ;процедура для виведення цілого числа
mov bx, num ;num записується до регістру  bx
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
ret ;возврат из ближней процедуры
digit endp ;переривання процедури

CSEG ENDS ;ознака кінця сегменту коду
END MAIN  ;ознака кінця програми
