.data
NUM0: .word 25
NOTAS0:0,0,60,1200,72,1200,71,600,67,500,69,500,71,500,60,800,69,600,67,600,57,1200,65,800,64,400,64,400,64,400,64,400,62,500,59,400,60,400,62,800,62,600,64,600,69,400,72,800
.text
.macro music_play(%NUM,%NOTAS,%a2,%a3) #ENDERE�O WORD DA QUANTIDADE DE NOTAS, ENDERE�O DAS NOTAS, INSTRUMENTO, VOLUME
    la s4 %NUM        # define o endereço do número de notas
    lw s5 0(s4)        # le o numero de notas
    la s4 %NOTAS        # define o endereço das notas
    li t0 0            # zera o contador de notas
    li a2 %a2        # define o instrumento
    li a3 %a3        # define o volume

LOOP_MUSIC:
	# Se chegar ao final do contador vai repetir
	lw a0 0(s4)            # le o valor da nota
        lw a1 4(s4)            # le a duracao da nota
        li a7 31            # define a chamada de syscall
        ecall
        #li a3 0                # toca a nota
        mv a0 a1            # passa a duração da nota para a pausa
        li a7 31
        #li a3 %a3            # define a chamada de syscal 
        ecall                # realiza uma pausa de a0 ms
        addi s4 s4 8            # incrementa para o endereço da próxima nota
        addi t0 t0 1            # incrementa o contador de notas
        beq t0 s5 REPEAT_MUSIC
        j LOOP_MUSIC
.end_macro
REPEAT_MUSIC:
	la s4 NOTAS0
	#li t0 0
	music_play(NUM0,NOTAS0,5,40)

music_play(NUM0,NOTAS0,5,40)
