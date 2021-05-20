# -----------------------------------------
# 		   Macros
# -----------------------------------------
# macro trecho de código (~chamada de função)

# -----------------------------------------
# 	Macros de operações:
# -----------------------------------------

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
.macro Exit()
	li a7,10 # Exit
	ecall
.end_macro

# ---------------------------------------
# 	"Funções" do Jogo
# ---------------------------------------

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

# passa o valor de um registrador para o registrador de movimento
.macro increment_pos_reg(%x,%y,%r1,%r2)
	mv %x,%r1
	mv %y,%r2
.end_macro

# incrementa o valor da posição pelo valor de outros 2 registradores
.macro increment_pos_numb(%x,%y,%r1,%r2)
	add %x,%x,%r1
	add %y,%y,%r2
.end_macro

# %r1 é o registrador do último movimento no eixo
# %DIR é a label que guarda a informação da última direção
.macro update_dir(%r1,%DIR,%temp)
	sh %r1,%DIR,%temp
.end_macro

# ANIMAÇÂO:
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

# %x_mv e %y_mv são os registradores que guardam a posição do lolo movimentado
# %imm_x e %imm_y são os imediatos que indicam o quanto os pixels do sprite devem ser deslocados
# %treg é o registrador de retorno
# OBS.: não passar t0 como argumento
.macro get_point(%x_mv,%y_mv,%imm_x,%imm_y,%treg)
	li t0,%imm_x
	sub t5,%x_mv,t0
	srli t5,t5,4
	li t0,%imm_y
	sub %treg,%y_mv,t0
	srli %treg,%treg,4
	li t0,11
	mul %treg,%treg,t0
	add %treg,%treg,t5
END_CHECK_HITBOX:
.end_macro

# %imm é o valor para o qual será settado a posição da matriz
# %jumper é o que será pulado na macro
.macro change_matrix_value(%enemy_xy,%matrix,%imm,%jumper)
	# encontrar enemey_matrix_pos a partir de x y
	la t1,%enemy_xy
	add t1,t1,%jumper
	lw t2,4(t1)
	lw t1,0(t1)
	get_point(t1,t2,56,32,t6) # retorna o ponto do inimigo na matriz
	slli t6,t6,2 # multiplica o ponto pelo número de intervalos da word
	la t0,%matrix
	add t0,t0,t6 # movimenta a matriz para o valor desejado
	lb t1,0(t0)
	li t2,%imm 
	mv t1,t2 # troca o valor anterior pelo novo
	sb t1,(t0)
.end_macro

# %sprite é o registrador que carrega a posição atual do sprite
# %imm é o imediato do collision type do lolo
# %matrix é a matriz do mapa
# t0 é o registrador de retorno
.macro check_col_type(%sprite,%imm,%matrix)
	slli t0,%sprite,2
	add t0,%matrix,t0
	lb t0,(t0)
	li t1,%imm
.end_macro

.macro get_col_pos(%pos,%matrix)
	slli t0,%pos,2
	add t0,%matrix,t0
.end_macro

# Os medidores de magnitude serão t0 e t1
# t0 é a magnitude de X
# t1 é a magnitude de Y
# t4 é o atualizador de posição
# t2 atualiza o state -> valor de true or false do input
# Checar se é para a direita
# Resetando os valores de t0 e t1 para 0

# -----------------------------------------
# Enemy Functions & Other Related Funcitons
# -----------------------------------------

# Enemy finder
# checar o matrix enemy count para saber o número de vezes que o loop deve rodar
# o loop roda recebendo várias labels de inimigos para encontrar o que atende à posição
.macro enemy_finder(%enemypos,%enemycount,%colisionposx,%collisionposy)
	la t4,%enemycount
	lw t4,0(t4) # dfine em t4 o valor máximo do contador
	find_dir(%label,%xdir,%ydir,%imm)
	la t1,%collisionposx
	lw t1,0(t1)
	la t2,%collisionposy
	lw t2,0(t2)
	# com as posições da colisão, encontrar o relativo dela na matriz
	li t3 0 # define o contador em 0
LOOKING_FOR_ENEMY:
	pp(t4)
.end_macro

# %r1 registrador de x
# %r2 registrador de y
.macro load_other_pos(%r1,%r2,%label)
	la t1,%label
	lh %r1,0(t1)
	lh %r2,4(t1)
.end_macro

.macro load_other_pos(%r1,%r2,%labelx,%labely)
	la t5,%labelx
	la t6,%labely
	lh %r1,0(t5)
	lh %r2,0(t6)
.end_macro

.macro find_grid_pos(%r1,%r2)
	li t0,320
	mul %r2,%r2,t0
	add %r2,%r2,%r1
.end_macro

# Lagarta
# recebe x da lagarta e x do lolo
# encontrar x da lagar + e - 16, para as posições 2 e 1, e 0 e 3 para x menores e maiores
.macro lagarta_dir(%lolo,%x,%label,%old_label)
	la t0,%label
	lb t0,0(t0)
	sb t0,%old_label,t1
	li t0,16
	bgt %lolo,%x,X_POS_CHECK
	sub t2,%x,%lolo
	ble t2,t0,HALF_DIR2
	li t1,3
	sb t1,%label,t2
	j END_UPDATE_OTHER_DIR
HALF_DIR2:
	li t1,2
	sb t1,%label,t2
	j END_UPDATE_OTHER_DIR
X_POS_CHECK:
	sub t2,%lolo,%x
	ble t2,t0,HALF_DIR1
	li t1,0
	sb t1,%label,t2
	j END_UPDATE_OTHER_DIR
HALF_DIR1:
	li t1,1
	sb t1,%label,t2

END_UPDATE_OTHER_DIR:
.end_macro

# encontra a posição superior esquerda de uma posição na matrix no grid 
# %r1 é o retorno de x
# %r2 é o retorno de y

# encontra a direção para a qual algum objeto estava se deslocando
# adiciona um valor de movimento (%imm) nessa direção
# %xdir e %ydir são os registradores que vão receber o valor do deslocamento de posição
.macro find_dir(%label,%xdir,%ydir,%imm)
	li %xdir 0
	li %ydir 0
	la t0,%label
	lb t0,0(t0)
	bnez t0,CHECK_IF_1
	li %xdir,%imm
	j DIR_FOUND
CHECK_IF_1:
	li t1,1
	bne t1,t0,CHECK_IF_2
	li %ydir,-%imm
	j DIR_FOUND
CHECK_IF_2:
	li t1,2
	bne t1,t0,IS_3
	li %xdir,-%imm
	j DIR_FOUND
IS_3:
	li %ydir,%imm
	mv a0,%ydir
DIR_FOUND:
.end_macro

# -------------------------
# Music & Sound Effects
# -------------------------
.macro sound_effect(%a0,%a1,%a2,%a3)
    li a0 %a0
    li a1 %a1
    li a2 %a2
    li a3 %a3
    li a7 31
    ecall
.end_macro

.macro play_music(%NUM,%NOTAS,%a2,%a3,%imm) #ENDEREÇO WORD DA QUANTIDADE DE NOTAS, ENDEREÇO DAS NOTAS, INSTRUMENTO, VOLUME
    la s4 %NUM                # define o endereÃ§o do nÃºmero de notas
    lw s5 0(s4)            #le o numero de notas
    la s4 %NOTAS            # define o endereÃ§o das notas
    li t0 0                # zera o contador de notas
    li a2 %a2            # define o instrumento
    li a3 %a3            # define o volume

LOOP_MUSIC:
                        # Se chegar ao final do contador vai repetir
        lw a0 0(s4)            # le o valor da nota
        lw a1 4(s4)            # le a duracao da nota
        li a7 31            # define a chamada de syscall
        ecall                       # toca a nota
        mv a0 a1            # passa a duraÃ§Ã£o da nota para a pausa
        li a7 %imm                       # define a chamada de syscal 
        ecall                # realiza uma pausa de a0 ms
        addi s4 s4 8            # incrementa para o endereÃ§o da prÃ³xima nota
        addi t0 t0 1            # incrementa o contador de notas
        beq t0 s5 REPEAT_MUSIC
        j LOOP_MUSIC     
                
REPEAT_MUSIC:
.end_macro

# ---------------------------
#  Map & Stage Functions
# ---------------------------
.macro upgrade_matrix(%current_map,%next_map)
	la t0,%current_map
	la t1,%next_map
	li t2,121 # tamanho máximo de qualquer matriz
	li t3,0 # contador da matriz
UPGRADING_THE_MATRIX:
	beq t3,t2,MATRIX_UPGRADED
	lb t4,0(t1)
	sb t4,0(t0)
	addi t1,t1,4
	addi t0,t0,4
	addi t3,t3,1
	j UPGRADING_THE_MATRIX
MATRIX_UPGRADED:
.end_macro

.macro load_enemy_xy(%current_pos,%new_pos)
	la t0,%current_pos
	la t1,%new_pos
	lb t2,0(t1)
	lb t3,4(t1)
	sb t2,0(t0)
	sb t3,4(t0)
.end_macro

.macro load_enemy_values(%current_value,%new_value)
	la t0,%current_value
	la t1,%new_value
	lb t1,0(t1)
	sb t1,0(t0)
.end_macro

# value_length é o label que contém o número de objetos que devem ser iterados
# %interval é um imm que indica o intervalo que eles devem assumir
.macro load_new_values(%current_value,%new_value,%value_length,%interval)
	la t0,%current_value
	la t1,%new_value
	la t2,%value_length # tamanho máximo de qualquer matriz
	lb t2,0(t2)
	li t3,0 # contador da matriz
UPGRADING_THE_MATRIX:
	beq t3,t2,MATRIX_UPGRADED
	lb t4,0(t1)
	sb t4,0(t0)
	addi t1,t1,%interval
	addi t0,t0,%interval
	addi t3,t3,1
	j UPGRADING_THE_MATRIX
MATRIX_UPGRADED:
.end_macro

.macro new2old_map(%current_map,%next_map)
	la t0,%current_map
	la t1,%next_map
	lw t2,0(t1)
	lw t3,4(t1)
	mul t2,t2,t3
	addi t0,t0,4
	addi t1,t1,4
	li t3,0 # contador da matriz
UPGRADING_THE_MATRIX:
	beq t3,t2,MATRIX_UPGRADED
	lb t4,0(t1)
	sb t4,0(t0)
	addi t1,t1,1
	addi t0,t0,1
	addi t3,t3,1
	j UPGRADING_THE_MATRIX
MATRIX_UPGRADED:
.end_macro




