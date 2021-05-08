# -----------------------------------------
# 		   Macros
# -----------------------------------------
# macro trecho de código (~chamada de função)

# multiplicador e divisor
# multiplica %reg por %imm e guarda em %result
# ou faz a mesma operação para divisão
.macro mult_div(%op,%result,%reg,%imm)
	li %result,%imm
	%op %result,%reg,%result
.end_macro

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

# r1 passa o número de pixels de todos os frames da imagem
# r2 passa o número de pixels de cada frame da imagem
# frame contém a label que guarda o último frame da imagem
# em ret fica o resultado de quantos pixels devem ser pulados para o novo ponto de início da imagem
.macro image_cicle(%sprite,%r1,%r2,%frame,%ret,%temp1,%temp3)
	la %ret,%frame
	lb %ret,0(%ret)
	addi %temp1,%ret,1
	mul %ret,%ret,%r2
	sb %temp1,%frame,%temp3
	# o valor dos frames deve ir de 0 até o valor de t1
	bge %ret,%r1,SKIP_FRAME
	j END_FRAME
SKIP_FRAME:
	sb zero,%frame,%temp1
	li %ret,0
END_FRAME:
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
PAUSE_GAME:
	li s3,ESC
	bne %reg,s3,RESTART
	j GLOBAL_PAUSE
RESTART:
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

# Ah, a parada da animação q eu falei, deu certo ss
# usei +- o que falei ontem msm, tem um vetor que armazena o último frame do lolo
# aí eu multiplico o valor do frame pelo numero de pixels de cada frame do lolo (16)
# e somo isso no ponto onde é para começar a printar os pixels do lolo
# se for maior do que o total de pixels de todos os frames de uma mesma direção ele volta para 0
