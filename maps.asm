.data
# ------------------------------------
# Valores dos elementos das matrizes
# ------------------------------------
# 0 - FREE: espa�os em que o lolo pode andar livremente
# 1 - WALL: colis�o com objetos s�lidos
# os valores de 2 at� 6 ser�o reservados para diferentes tipos de inimigos?
# 7 - HEARTS: cora��es colet�veis. N�o possuem colis�o
# 8 - CHESTS: ba�s - possuem colis�o enquanto o Lolo n�o tiver coletado todos os cora��es
# 9 - DOOR: sa�da da fase
# os valores podem crescer para alem de n�meros de 1 d�gito

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
	
# Posi��o dos cora��es
# 1: X: 120 Y: 48
