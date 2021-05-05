
.data
# QUANTIDADE DE NOTAS
NUM: .word 25

# NOTAS...DURAÇÃO
NOTAS:0,0,60,1200,72,1200,71,600,67,500,69,500,71,500,60,800,69,600,67,600,57,1200,65,800,64,400,64,400,64,400,64,400,62,500,59,400,60,400,62,800,62,600,64,600,69,400,72,800
.text
	la s0 NUM		# define o endereço do número de notas
	lw s1 0(s0)		# le o numero de notas
	la s0 NOTAS		# define o endereço das notas
	li t0 0			# zera o contador de notas
	li a2 5			# define o instrumento
	li a3 100		# define o volume

LOOP:	beq t0 s1 REPEAT	# Se chegar ao final do contador vai repetir
	lw a0 0(s0)		# le o valor da nota
	lw a1 4(s0)		# le a duracao da nota
	li a7 31		# define a chamada de syscall
	ecall			# toca a nota
	mv a0 a1		# passa a duração da nota para a pausa
	li a7 32		# define a chamada de syscal 
	ecall			# realiza uma pausa de a0 ms
	addi s0 s0 8		# incrementa para o endereço da próxima nota
	addi t0 t0 1		# incrementa o contador de notas
	j LOOP	
				# volta ao loop

REPEAT:
	la s0 NOTAS		# CARREGAR NOVAMENTE EM S0 A LABEL NOTAS
	li t0 0			# ZERAR O CONTADOR
	j LOOP 			# REPETIR O LOOP			

 #PARA EXECUTAR EM OUTRO ARQUIVO, BASTA FAZER UM .INCLUDE E CHAMAR ECALL
