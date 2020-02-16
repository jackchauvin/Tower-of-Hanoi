@ Move-2 Towers of Hanoi: a variation on the Towers of Hanoi 

@ In Move-2 Towers of Hanoi, in each move you are allowed to
@ move either 1 or 2 disks at the same time. The goal is the same.
@ Moving 2 disks at a time just means the tower can be solved faster.

@
@ Data Section
@
.data

@
@ Messages
@
prompt: .asciz "Enter the number of disks : "

zerodisk: .asciz "Towers of Hanoi makes no sense with %d disks\n"
  
statement: .asciz "The moves to solve the Move-2 Tower of Hanoi are :\n"

moving2: .asciz "Moving disks %d and %d"

from2: .asciz " from peg %d to peg %d\n"

move1: .asciz "Move disk %d from peg %d to peg %d\n"
 
@
@ Input buffer
@
.set BUFFERSIZE,100

buffer: .space BUFFERSIZE,0

@
@ Text Section
@
.text
.global main

main:
 
  stmfd sp!,{r4,lr}   @ Stores r4 and lr to stack

  @ Prompts for number of disks
  ldr r0,=prompt
  bl printf
          
  @ fgets(buffer, sizeof(buffer), stdin)
  ldr r0,=buffer      @ Argument 1: buffer address
  ldr r1,=BUFFERSIZE  @ Argument 2: size of the buffer
  ldr r2,=stdin       @ Address of stdin variable in memory
  ldr r2,[r2]         @ Argument 3: value of stdin
  bl fgets
  
  @ Convert to an integer
  ldr r0,=buffer
  bl atoi

  movs r4,r0          @ Checks if disks = 0 

  bne not_zero        @ Jumps ahead if != 0

@ Moves here if 0
done_zero:

  mov r1,r0           @ Number of disks
  ldr r0,=zerodisk    @ Prints msg 
  bl printf
  ldmfd sp!,{r4,lr}   @ Loads r4 and lr from stack
  bx lr               @ Exits function 

@ Goes here if disks != 0
not_zero:  
 
  @ Prints beginning statement
  ldr r0,=statement
  bl printf

  @ hanoi2(int num, int frompeg, int topeg, int auxpeg)
  mov r0,r4  @ Argument 1: num    
  mov r1,#1  @ Argument 2: from peg
  mov r2,#2  @ Argument 3: to peg
  mov r3,#3  @ Argument 4: aux peg
  bl hanoi2

  ldmfd sp!,{r4,lr}
  bx lr

@ Recursive function that moves num disks from
@ frompeg to topeg using auxpeg as an intermediate
@ storage location. One or two disks can be moved
@ at a time
hanoi2:
  stmfd sp!,{r5-r8,lr}  @ Stores r5-r8,lr to stack 
  
  num .req r5           @ Sets aliases
  from .req r6
  to .req r7
  aux .req r8

  mov num,r0            @ Sets values
  mov from,r1
  mov to,r2
  mov aux,r3

  cmp num,#1            @ If num < 1: exit current call
  blt hanoi2_done  
  
  @recursion here 
  @hanoi2(num-2,frompeg,auxpeg,topeg)
  sub r0,num,#2  @ Argument 1: num-2
  mov r1,from    @ Argument 2: from peg
  mov r2,aux     @ Argument 3: aux peg
  mov r3,to      @ Argument 4: to peg
  bl hanoi2

  cmp num,#2    
  blt onedisk    @ num < 2: move one disk
  bge twodisk    @ num >= 2: move two disks  

back:            @ return point from printing
  
  @recursion here 
  @hanoi2(num-2,auxpeg,topeg,frompeg)  
  sub r0,num,#2  @ Argument 1: num-2
  mov r1,aux     @ Argument 2: aux peg
  mov r2,to      @ Argument 3: to peg
  mov r3,from    @ Argument 4: from peg
  bl hanoi2

  b hanoi2_done

@
@ hanoi2 printing statements
@

@ Prints when 2 disks are moved
twodisk:            
  @ printf("Moving disks %d and %d", num-1, num)
  ldr r0,=moving2  @ Argument 1: string
  sub r1, num,#1   @ Argument 2: num-1
  mov r2,num       @ Argument 3: num
  bl printf
  @ printf(" from peg %d to peg %d\n", frompeg, topeg);
  ldr r0,=from2    @ Argument 1: string
  mov r1,from      @ Argument 2: from peg
  mov r2,to        @ Argument 3: to peg
  bl printf

  b back           @ Back to function 

@ Prints when 1 disk is moved
onedisk:             
  @ printf("Move disk %d from peg %d to peg %d\n", num, frompeg, topeg);
  ldr r0,=move1    @ Argument 1: string
  mov r1,num       @ Argument 2: num
  mov r2,from      @ Argument 3: from peg
  mov r3,to        @ Argument 4: to peg 
  bl printf

  b back           @ Back to function

@
@ End of hanoi2 function
@ Exits current call of hanoi2 to correct spot
hanoi2_done:
  
  ldmfd sp!,{r5-r8,lr}  @ Loads r5-r8,lr from stack
  bx lr                 @ Returns from function

  .unreq num            @ Unsets aliases
  .unreq from 
  .unreq to 
  .unreq aux