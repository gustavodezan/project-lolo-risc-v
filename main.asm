.data
.include "./scripts/macros.asm"
.include "./scripts/andar.asm"
.eqv MMIO_add 0xff200004 # Data (ASCII value)
.eqv MMIO_set 0xff200000 # Control (boolean)
# ----------------------
# Player State Machine
# ----------------------
# 0 - Player State Free
# 1 - Player State WALK
# 3 - DEATH?
LOLO_FRAME: .byte 0	# o lolo possui 5 frames para cada dir. Como definir isso mais adiante para os inimigos?
POS_X:  .half 0               # x e y
POS_Y:  .half 0

# POS_MATRIX
#POS_M:


# O vetor DIR guarda a última direção para a qual o sprite olhou
# Vai de 0 até 3, seguindo o sentido de um plano cartesiano
DIR:    .byte 1
COL1_NUM: .word 132
MAP1_COL: 0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 7, 0, 8, 0, 10, 0, 0, 1, 1, 1, 2, 1, 3, 1, 7, 1, 8, 1, 10, 1, 1, 2, 2, 2, 3, 2, 4, 2, 5, 2, 7, 2, 8, 2, 9, 2, 10, 2, 2, 3, 3, 3, 4, 3, 5, 3, 7, 3, 8, 3, 9, 3, 10, 3, 4, 4, 5, 4, 7, 4, 8, 4, 9, 4, 8, 5, 1, 6, 2, 6, 0, 7, 1, 7, 2, 7, 3, 7, 7, 7, 8, 7, 0, 8, 1, 8, 2, 8, 3, 8, 7, 8, 8, 8, 9, 8, 0, 9, 1, 9, 2, 9, 3, 9, 8, 9, 9, 9, 0, 10, 1, 10, 2, 10, 3, 10, 4, 10, 5, 10

NUM0: .word 25
NOTAS0:0,0,60,1200,72,1200,71,600,67,500,69,500,71,500,60,800,69,600,67,600,57,1200,65,800,64,400,64,400,64,400,64,400,62,500,59,400,60,400,62,800,62,600,64,600,69,400,72,800
#a2=5 
#a3=100 

# Obs.: talvez seja necessário diminuir a quantidade de includes? Se não, passar as .eqv para outra pasta

.text
# -----------------------------------------------------------------------------
# Imprimir na tela o menu inicial
# -----------------------------------------------------------------------------
li s0,0xFF100000


LOAD_GAME_START:

	li s1,160
	li s2,120
	update_pos(s1,s2,POS_X,POS_Y,t2)	
	li a6,40
	
	print_img(Adventures_of_Lolo_Title,a6,s6,0xFF100000) # title é a correta para 320 x 240, Adventures_of_Lolo_Title é para 240 x 240
	li s0,0xFF200604
	li t2,1
	sw t2,0(s0)
	print_img(map_start,a6,s0,0xFF000000) # title é a correta para 320 x 240, Adventures_of_Lolo_Title é para 240 x 240
	li a6,0
	
WAIT_START:
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, WAIT_START # wait time enquanto ready bit == 0
	
# Receber o input do teclado
# Após isso movimentar o personagem
# A movimentação ainda não está de acordo com o tipo de input -> implementar em andar.asm

LOAD_MAP_START:
	print_img(clean_back,a6,s6,0xFF100000)
	sw t2,0(s0)
	li s0,0xFF200604
	li t2,0
	sw t2,0(s0)
GAME_LOOP:
	#Song(NUM0,NOTAS0,5,100)
	load_pos(POS_X,POS_Y,s1,s2)
	li t1,0
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, GAME_LOOP # wait time enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
	#check_state(a0,STATE,t2)
	andar(a0,lolo_4_dir,lolo_walk,map_start,s1,s2)
	
	j GAME_LOOP
	Exit()
	
GLOBAL_PAUSE:
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, GLOBAL_PAUSE # wait time enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
	li s3,ESC
	beq a0,s3,GAME_LOOP
	j GLOBAL_PAUSE
	

# Pensamentos sobre a impressão de imagens:
# para printar uma imagem na tela com o script (em andar.asm) todos os registradores temp são usados,
# por conta disso, talvez gere complicações realizar algo mais detalhado do que isso. (-> hora de receber input do teclado)
# também armazenamos em um registrador salvo (s10) a última posição da imagem. Para poupar registradores
# não tem mais registradores temporários para essa função durante a execução do script... :)
# Registradores salvos utilizados:
# s0 -> é definido na hora de printar a imagem em seu valor base; depende de s10
# s1 -> X
# s2 -> Y
# s3 -> check_input
# s9 -> dimensão máxima da tela (é definido sempre que é necessário)
# s10 -> vetor de x por y
# Com o uso de s1 e s2 para determinar o a posição na tela sempre que algo for andar, fica mais fácil de implementar
# o desenho de partes menores do mapa.
.data
# -----------------------------------------
# 	   INCLUDES + EQUIVALENTES
# -----------------------------------------
.include "./assets/assets_data/lolo_4_dir.data"
.include "./assets/assets_data/Adventures_of_Lolo_Title.data"
.include "./assets/assets_data/lolo_walk.data"
.include "./assets/assets_data/clean_back.data"
.include "./assets/assets_data/map_start.data"
#.include "./scripts/ost.asm"
