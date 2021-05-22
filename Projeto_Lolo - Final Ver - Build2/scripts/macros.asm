.eqv RIGHT 100
.eqv UP 119
.eqv LEFT 97
.eqv DOWN 115
.eqv FOUR 4
.eqv ESC 27
.eqv R 114
.eqv SPACE 32


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

# Delay
.macro delay(%imm_time)
li a7,32
li a0,%imm_time
ecall
.end_macro

# ---------------------------------------
# 	"Funções" do Jogo
# ---------------------------------------

# ---------------------------------------
# Funções de Imagem
# ---------------------------------------
.macro animate_sprite(%sprite,%grid_reg,%frame,%dir)
	la t0,%sprite # carregar o endereço do sprite em t0 apenas para passar para t1 e t2
	lw t1, 0(t0) # x -> primeira word - inicia em 0xFF000000 e termina em 0xFF00013F
	lw t2, 4(t0) # y -> segunda word
	mul t3,t2,t2 # y * y para obter a área -> t3 = área (16x16)
	addi t0,t0,8
	# Definir a posição inicial da imagem na tela
	li s0, 0xFF000000
	add s0,s0,%grid_reg
	sub s8,t1,t2 # Encontrar valor de line_break para os pixels
	# t1 passa o valor da dimensão x total da imagem, não de um único frame
	mult_div(div,t6,t1,4)
	mv t1,t6 # transformar t1 no valor de um frame e não do sprite inteiro -> totalFrames
	la t4,%dir
	lb t4,0(t4)
	mul t4,t1,t4
	add t0,t0,t4
	image_cicle(%sprite,t1,t2,%frame,t4,t5,t6)
	add t0,t0,t4
	# Encontrar o nº de pixels a serem pulados
	li s9,320 # dimensão máxima da tela
	sub t1,s9,t2 # t2 armazena da dimensão máxima - o valor x do sprite
	mv s9,s8 # usar s9 como val de line_break
	li t6,0 # contador quebra de linha
	li t4, 0 # contador de parada
IMPRIMEA:
	bge t4, t3, BREAK_ANIMATION
	bge t6,t2, NEW_LINEA
	lw t5, 0(t0)
	sw t5, 0(s0)
	addi t0,t0,4
	addi s0,s0,4
	addi t4,t4,4
	addi t6,t6,4
	j IMPRIMEA
NEW_LINEA:
	add s0,s0,t1
	add t0,t0,s9 # valor de line_break com retorno para o mesmo ponto inicial em X na linha seguinte
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j IMPRIMEA
BREAK_ANIMATION:
.end_macro

# Print Image
# %sprite passa o sprite que será movimentado
# %grid_reg passa o registrador que contém a informação de onde a imagem deve aparecer na tela
.macro print_img(%sprite,%grid_reg,%f_reg,%f_adress)
	la t0,%sprite # carregar o endereço de tela em t0
	lw t1, 0(t0) # x -> primeira word - inicia em 0xFF000000 e termina em 0xFF00013F
	lw t2, 4(t0) # y -> segunda word
	mul t3,t1,t2 # x * y para obter a área -> t3 = área
	addi t0,t0,8 # 0 é x, 4 é y, portanto em 8 começa a imagem
	li %f_reg, %f_adress
	li s9,320 #dimensão máxima da tela
	sub t2,s9,t1
	add %f_reg,%f_reg,%grid_reg
	li t6,0 # contador quebra de linha
	li t4, 0 # contador de parada
IMPRIME:
	bge t4, t3, BREAK_PRINT
	bge t6,t1, NEW_LINE 
	lw t5, 0(t0)
	sw t5, 0(%f_reg)
	addi t0,t0,4
	addi %f_reg,%f_reg,4
	addi t4,t4,4
	addi t6,t6,4
	j IMPRIME
NEW_LINE: 
	add %f_reg,%f_reg,t2
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j IMPRIME
BREAK_PRINT:
.end_macro

# Player collision deve vir sempre que for chamada a função de movimentar o jogador
# Desse modo, será checado se há colisão no próximo espaço que o Lolo irá ocupar
# se houver, ele não movimenta, se estiver livre, ele movimenta normalmente
.macro check_collision(%x,%y,%x_mv,%y_mv,%col_type)
	# Checar se está em uma das bordas do mapa
	# como todas as unidades estão sujeitas ao mapa, serve para todas
	mv t5,%x_mv
	mv t6,%y_mv
	add %x_mv,%x,%x_mv
	add %y_mv,%y,%y_mv
	li t0,52 # pixel x onde começa o mapa, após a parede
	li t1,28 # pixel y onde começa o mapa, após a parede
	ble %x_mv,t0,V_END_CHECK_COL # checar colisão na esquerda
	ble %y_mv,t1,V_END_CHECK_COL # checar colisão encima
	li t0,220
	li t1,196
	bge %x_mv,t0,V_END_CHECK_COL # checar colisão na direita
	bge %y_mv,t1,V_END_CHECK_COL #checar colisão inferior
	
CHECK_COL_STEP2:
	# Passo 2:
	# checar se há algum objeto com colisão perto
	li a7,1
	la s8,CURRENT_MAP
	li t4,0

# SUPERIOR_ESQUERDO: X = 56 Y = 32
# SUPERIOR_DIREITO: X = 44 Y = 32
# INFERIOR_ESQUERDO: X = 56 Y =¨20
# INFERIOS_DIREITO: X = 44 Y = 20
	j START_POINT_CHECKING
	
V_END_CHECK_COL: j END_CHECK_COLLISION
V_CHECK_COLLISION_TYPE: j CHECK_COL_TYPE

START_POINT_CHECKING:
	get_point(%x_mv,%y_mv,56,32,s3)
	check_col_type(s3,1,s8)
	beq t1,t0,V_END_CHECK_COL
	li t1,2
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,6
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,7
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,8
	beq t1,t0,V_END_CHECK_COL
	
	get_point(%x_mv,%y_mv,44,32,s3)
	check_col_type(s3,1,s8)
	beq t1,t0,V_END_CHECK_COL
	li t1,2
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,6
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,7
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,8
	beq t1,t0,V_END_CHECK_COL
	
	get_point(%x_mv,%y_mv,56,20,s3)
	check_col_type(s3,1,s8)
	beq t1,t0,V_END_CHECK_COL
	li t1,2
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,6
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,7
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,8
	beq t1,t0,V_END_CHECK_COL
	
	get_point(%x_mv,%y_mv,44,20,s3)
	check_col_type(s3,1,s8)
	beq t1,t0,V_END_CHECK_COL
	li t1,2
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,6
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,7
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,8
	beq t1,t0,V_END_CHECK_COL

ESCAPE_CHECK_COL:
	increment_pos_reg(%x,%y,%x_mv,%y_mv)
	li %col_type,0
	j END_CHECK_COLLISION
CHECK_COL_TYPE:
	bnez %col_type,NEXT_CHECK_COL0
	li t0,7
	bne t0,t1,NEXT_CHECK_COL0
	call HEARTS_ROUTINE
NEXT_CHECK_COL0:
	li t0,6
	bne t0,t1,NEXT_CHECK_COL1
	call CHEST_ROUTINE
NEXT_CHECK_COL1:
	beqz %col_type,V_END_CHECK_COL
	mv %col_type,t1 # se a colisão for do poder, informar que a colisão ocorreu

END_CHECK_COLLISION:
.end_macro


.macro clear_sprite(%old_sprite,%x,%y)
CLEAR:
	li s9,320
	mul s10,%y,s9
	add s10,s10,%x
	li t1,16
	mul t3,t1,t1 # x * y para obter a área -> t3 = área
	la t0,%old_sprite # carregar em t0 o valor do sprite anterior, para acessar as cores dele
	addi t0,t0,8
	li s0, 0xFF000000
	add s0,s0,s10
	li s9,320 # dimensão máxima da tela
	sub t2,s9,t1
	# Como X e Y não estão em vetor, posso facilmente achar a posição relativa do background em 240x240
	la s9,%old_sprite
	lw s9,0(s9) # armazenar em s9 o valor y do mapa
	mul s10,%y,s9
	li s9,40
	sub s9,%x,s9
	add s10,s10,s9
	add t0,t0,s10
	la s9,%old_sprite
	lw s9,0(s9) # armazenar em s9 o valor X do mapa
	sub s9,s9,t1 # subtrair X do sprite de X do mapa
	li t6,0 # contador quebra de linha
	li t4, 0 # contador de parada
CLEAR_LOOP:
	bge t4, t3, END_CLEAR
	bge t6,t1, CLEAR_LINE
	lw t5,0(t0)
	sw t5, 0(s0)
	pp(t0,4)
	pp(s0,4)
	pp(t4,4)
	pp(t6,4)
	j CLEAR_LOOP
CLEAR_LINE:
	add s0,s0,t2
	add t0,t0,s9 # valor de line_break com retorno para o mesmo ponto inicial em X na linha seguinte
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j CLEAR_LOOP
END_CLEAR:
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
	get_point(t1,t2,56,32,s3) # retorna o ponto do inimigo na matriz
	slli s3,s3,2 # multiplica o ponto pelo número de intervalos da word
	la t0,%matrix
	add t0,t0,s3 # movimenta a matriz para o valor desejado
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

.macro load_other_pos(%r1,%r2,%labelxy,%jumper)
	li t6,2
	mul t6,%jumper,t6
	la t5,%labelxy
	add t5,t5,t6
	lh %r1,0(t5)
	lh %r2,4(t5)
.end_macro

.macro find_grid_pos(%r1,%r2)
	li t0,320
	mul %r2,%r2,t0
	add %r2,%r2,%r1
.end_macro

# Lagarta
# recebe x da lagarta e x do lolo
# encontrar x da lagar + e - 16, para as posições 2 e 1, e 0 e 3 para x menores e maiores
.macro lagarta_dir(%lolo,%x,%label,%old_label,%jumper)
	la t4,%label
	add t4,t4,%jumper
	lb t0,0(t4) # load byte da direção acrescida de¨%jumper em t0
	la t1,%old_label
	add t1,t1,%jumper
	sb t0,0(t1) # salvar em %old_label o valor de t0 (que representa o último valor de dir)
	li t0,16
	la t3,%lolo # carrega em t3 a Label de posição do Lolo
	lh t3,0(t3)
	bgt t3,%x,X_POS_CHECK # compara a posição do Lolo com a posição armazenada em a5 (%x) do inimigo
	sub t2,%x,t3 #armazena em t3 a diferença das posições (sempre por valores positivos)
	ble t2,t0,HALF_DIR2
	li t1,3
	sb t1,0(t4)
	j END_UPDATE_OTHER_DIR
HALF_DIR2:
	li t1,2
	sb t1,0(t4)
	j END_UPDATE_OTHER_DIR
X_POS_CHECK:
	sub t2,t3,%x
	ble t2,t0,HALF_DIR1
	li t1,0
	sb t1,0(t4)
	j END_UPDATE_OTHER_DIR
HALF_DIR1:
	li t1,1
	sb t1,0(t4)

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
	addi t1,t1,4
	addi t0,t0,4
	addi t3,t3,1
	j UPGRADING_THE_MATRIX
MATRIX_UPGRADED:
.end_macro

.macro load_new_collect(%current_value,%new_value,%value_length)
	la t0,%current_value
	la t1,%new_value
	la t2,%value_length # tamanho máximo de qualquer matriz
	lb t2,0(t2)
	li t3,0 # contador da matriz
LOADING_COLLECTABLES:
	beq t3,t2,COLLECTABLES_LOADED
	lb t4,0(t1)
	sb t4,0(t0)
	lb t4,4(t1)
	sb t4,4(t0)
	addi t1,t1,8
	addi t0,t0,8
	addi t3,t3,1
	j LOADING_COLLECTABLES
COLLECTABLES_LOADED:
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




