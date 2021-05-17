.data
.include "./scripts/macros.asm"
.include "./scripts/andar.asm"
.include "./scripts/maps.asm"
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
# O vetor DIR guarda a última direção para a qual o sprite olhou
# Vai de 0 até 3, seguindo o sentido de um plano cartesiano
DIR:    .byte 3

POWER: .half 2
MAP: .byte 0
CHEST: .half 0

FALSE: .byte 0
.text
# -----------------------------------------------------------------------------
# Imprimir na tela o menu inicial
# -----------------------------------------------------------------------------
li s0,0xFF100000


LOAD_GAME_START:
	# carrega em s1 e s0 as posições de início do lolo
	li s1,56
	li s2,112
	update_pos(s1,s2,POS_X,POS_Y,t2)	
	li a6,40
	# printa o menu no frame 1 enquanto printa o mapa no frame 0
	print_img(Adventures_of_Lolo_Title,a6,s6,0xFF100000) # title é a correta para 320 x 240, Adventures_of_Lolo_Title é para 240 x 240
	li s0,0xFF200604
	li t2,1
	sw t2,0(s0)
	print_img(map_start,a6,s0,0xFF000000)
	li a6,0
	
WAIT_START:
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, WAIT_START # wait time enquanto ready bit == 0

LOAD_MAP_START:
	# Elementos do Mapa 1
	# Corações
	li a6 15480
	print_img(collectable,a6,s0,0xFF000000)
	li a6, 30936
	print_img(collectable,a6,s0,0xFF000000)
	li a6, 56440
	animate_sprite(chests,a6,CHEST,CHEST)
	# -------------------------------------
	# Load HUD
	li a6,248
	print_img(hud,a6,s0,0xFF000000)
	li a6,5368
	animate_sprite(lolo_4_dir,a6,FALSE,DIR)
	li a6,15608
	#animate_sprite(digits,a6,LOLO_FRAME,DIR)
	# -------------------------------------
	
	
	li a6,40
	print_img(clean_back,a6,s6,0xFF100000)
	li a6,0
	sw t2,0(s0)
	li s0,0xFF200604
	li t2,0
	sw t2,0(s0)
GAME_LOOP:
	load_pos(POS_X,POS_Y,s1,s2)
	li t1,0
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, GAME_LOOP # wait time enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
	move(a0,lolo_4_dir,lolo_walk,map_start,s1,s2)
	
	# Update HUD
	
	j GAME_LOOP
	Exit()
	
GLOBAL_PAUSE:
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, GLOBAL_PAUSE # wait time enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
	li s3,ESC
	bne a0,s3,GAME_LOOP
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
# s11 -> mapa atual
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
.include "./assets/assets_data/collectable.data"
.include "./assets/assets_data/digits.data"
.include "./assets/assets_data/hud.data"
.include "./assets/assets_data/chests.data"
#.include "./scripts/ost.asm"
