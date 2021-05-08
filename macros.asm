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

# -------------------
# Funções de Posição
# -------------------
# Carrega o valor armazenado nas labels de posição nos registradores de movimento
.macro load_pos(%label_x,%label_y, %x, %y)
	la %x,%label_x
	la %y,%label_y
	lh %x,0(%x)
	lh %y,0(%y)
.end_macro

# Carrega o valor dos registradores de movimento nas labels de posição
.macro update_pos(%x,%y,%label_x,%label_y,%temp)
	sh %x,%label_x,%temp
	sh %y,%label_y,%temp
.end_macro

.macro increment_pos_reg(%x,%y,%r1,%r2)
	add %x,%x,%r1
	add %y,%y,%r2
.end_macro

# %r1 é o registrador do último movimento em x
# %r2 é o registrador do último movimento em y
# %DIR é a label que guarda a informação da última direção
.macro update_dir(%r1,%DIR,%temp)
	sh %r1,%DIR,%temp
.end_macro

# Checar se o player estava andando ou não
.macro check_state(%reg,%state,%temp)
	check_input(%reg)
	bnez t2,CHANGE_STATE
	j RESET_STATE
CHANGE_STATE:
	la %reg,%state
	lh %reg,0(%reg)
	addi %reg,%reg,1
	sh %reg,%state,%temp
	j END_CHECK_STATE
RESET_STATE:
	sh zero,%state,%temp
END_CHECK_STATE:
.end_macro

# Os medidores de magnitude serão t0 e t1
# t0 é a magnitude de X
# t1 é a magnitude de Y
# t4 é o atualizador de posição
# t2 atualiza o state -> valor de true or false do input
# Checar se é para a direita
# Resetando os valores de t0 e t1 para 0
.macro check_input(%reg)
	li t0,0
	li t1,0
	li t2,0
	li s3,R
	bne %reg,s3,W_RIGHT
	j LOAD_GAME_START
W_RIGHT:
	li s3,RIGHT
	bne %reg,s3,W_UP
	li t0,1
	li t4,0
	li t2,1
W_UP:
	li s3,UP
	bne %reg,s3,W_LEFT
	li t1,-1
	li t4,1
	li t2,1
W_LEFT:
	li s3,LEFT
	bne %reg,s3,W_DOWN
	li t0,-1
	li t4,2
	li t2,1
W_DOWN:
	li s3,DOWN
	bne %reg,s3,END_CHECK_INPUT
	li t1,1
	li t4,3
	li t2,1
END_CHECK_INPUT:
.end_macro

.macro read_char()
	li a7, 12
	ecall
.end_macro

.macro Exit()
	li a7,10 # Exit
	ecall
.end_macro


