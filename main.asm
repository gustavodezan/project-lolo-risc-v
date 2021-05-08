.data
# -----------------------------------------
# 	   INCLUDES + EQUIVALENTES
# -----------------------------------------
.include "./assets/assets_data/title.data"
.include "./assets/assets_data/Adventures_of_Lolo_Title.data"
.include "./assets/assets_data/lolo_walk.data"
.include "./scripts/macros.asm"
.include "./scripts/andar.asm"
.include "./scripts/mapa.asm"
.eqv MMIO_add 0xff200004 # Data (ASCII value)
.eqv MMIO_set 0xff200000 # Control (boolean)

# ----------------------
# Player State Machine
# ----------------------
# 0 - Player State Free
# 1 - Player State WALK
# 3 - DEATH?
STATE:	.byte 0, 0		# Seria útil diferenciar state free de state walk?
POS_X:  .half 0               # x e y
POS_Y:  .half 0
# O vetor DIR guarda a última direção para a qual o sprite olhou
# Vai de 0 até 3, seguindo o sentido de um plano cartesiano
DIR:    .byte 1


# Obs.: talvez seja necessário diminuir a quantidade de includes? Se não, passar as .eqv para outra pasta

.text
# -----------------------------------------------------------------------------
# Imprimir na tela o menu inicial
# -----------------------------------------------------------------------------

LOAD_GAME_START:
	li s1,160
	li s2,120
	update_pos(s1,s2,POS_X,POS_Y,t2)	
	li a6,40
	print_img(Adventures_of_Lolo_Title,a6) # title é a correta para 320 x 240, Adventures_of_Lolo_Title é para 240 x 240
	li a6,0
	
# Receber o input do teclado
# Após isso movimentar o personagem
# A movimentação ainda não está de acordo com o tipo de input -> implementar em andar.asm
GAME_LOOP:
	load_pos(POS_X,POS_Y,s1,s2)
	
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, GAME_LOOP # wait time enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
	#check_state(a0,STATE,t2)
	andar(a0,lolo_4_dir,lolo_walk,Adventures_of_Lolo_Title,s1,s2)
	
	j GAME_LOOP
	Exit()
# Pensamentos sobre a impressão de imagens:
# para printar uma imagem na tela com o script (em andar.asm) todos os registradores temp são usados,
# por conta disso, talvez gere complicações realizar algo mais detalhado do que isso. (-> hora de receber input do teclado)
# também armazenamos em um registrador salvo (s10) a última posição da imagem. Para poupar registradores
# não tem mais registradores temporários para essa função durante a execução do script... :)
# Registradores salvos utilizados:
# s0 -> é definido na hora de printar a imagem em seu valor base; depende de s10
# s1 -> X
# s2 -> Y
# s9 -> dimensão máxima da tela (é definido sempre que é necessário)
# s10 -> vetor de x por y
# Com o uso de s1 e s2 para determinar o a posição na tela sempre que algo for andar, fica mais fácil de implementar
# o desenho de partes menores do mapa.





