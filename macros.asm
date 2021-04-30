# -----------------------------------------
# 		   Macros
# -----------------------------------------
# macro trecho de código (~chamada de função)
# +=
.macro pp(%reg,%int)
	addi %reg,%reg,%int
.end_macro

# ++
.macro pp(%reg)
	pp(%reg,1)
.end_macro

# Ecalls
.macro System(%op)
	li a7,%op
	ecall
.end_macro

.macro System(%op, %reg)
	li a7,%op
	mv a0,%reg
	ecall
.end_macro

.macro print_mem(%label)
	li a7,4 
	la a0, %label
	ecall
.end_macro

.macro printf(%str)
.data
texto: .string %str
.text
	li a7, 4 # Print String
	la a0, texto
	ecall
.end_macro

.macro read_char()
	li a7, 12
	ecall
.end_macro

.macro Exit()
	li a7,10 # Exit
	ecall
.end_macro


