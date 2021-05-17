.data
# ------------------------------------
# Valores dos elementos das matrizes
# ------------------------------------
# 0 - FREE: espaços em que o lolo pode andar livremente
# 1 - WALL: colisão com objetos sólidos
# os valores de 2 até 6 serão reservados para diferentes tipos de inimigos?
# 7 - HEARTS: corações coletáveis. Não possuem colisão
# 8 - CHESTS: baús - possuem colisão enquanto o Lolo não tiver coletado todos os corações
# 9 - DOOR: saída da fase
# os valores podem crescer para alem de números de 1 dígito

# ----------------
# MAPA 1:
# ----------------
MAP0:	1,1,1,1,1,1,0,1,1,0,1,
	1,1,1,1,7,0,0,1,1,0,1,
	0,1,1,1,1,1,0,1,1,1,1,
	0,0,1,1,1,1,0,1,1,1,1,
	0,0,0,0,1,1,0,1,1,1,7,
	0,0,0,0,0,0,0,0,1,0,0,
	0,1,1,0,0,0,0,0,0,0,0,
	1,1,1,1,0,0,0,1,1,0,0,
	1,1,1,1,0,0,0,1,1,1,0,
	1,1,1,1,8,0,0,0,1,1,0,
	1,1,1,1,1,1,0,0,0,0,0
	
# Posição dos corações
# 1: X: 120 Y: 48
