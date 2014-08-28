#!/bin/bash
#commit-and-push.sh
#
# Script para fazer o commit para o repositorio local e o push para o repositorio remoto do GIT
# O commit+push somente ira ser executado se o desenvolvedor estiver na linha de desenv. Desenv.
# Caso o desenvolvedor estiver dentro de alguma Feature sera realizado somente o commit local.
# 
# Versao 1: Faz os commits locais e o push para o servidor. 
# Versao 2: Correcoes de estrutura
# Por Luiz Claudio - NeoAssist - 18-07-2013
#

# MODULOS
MODULO=1

case $MODULO in
	'1')	MODULOATIVO='Compatibility'
		;;
        '2')	MODULOATIVO='FrontEnd'
		;;
        '3')	MODULOATIVO='Libs'
		;;
        '4')	MODULOATIVO='PHPEndpoints'
		;;
        '5')	MODULOATIVO='Restler3'
		;;
        '6')	MODULOATIVO='Services'
		;;
        '7')	MODULOATIVO='WebRoot'
		;;
        *) echo "Erro no modulo"; exit;;
esac 

FUNC=`echo "$MODULOATIVO" | tr [:upper:] [:lower:]`

## Funcoes INICIO ##

# Funcao para enviar a mensagem para a troca de status do ticket.
Trata_TKT () {
echo "Vai atualizar algum ticket? [s/n]"; read TEMTKT

case $TEMTKT in
	'n') 	echo "Nenhum ticket sera atualizado!";;
	's') 	echo "Este script ira atualizar os tickets para o status 'Ready for Tests'"
		echo "Digite os tickets. Ex: #TKT-1, #TKT-2 | Colocar sempre a sinal '#' antes de cada ticket!! |"; read TKT
		if [[ -n $TKT ]]; then
			echo "Marcando os tickets para o status de Pronto para Testes"
			TICKETS=`echo "(${TKT}) Pronto para Testes"`
		else
			echo "Ticket invalido!"
		fi;;
	'*')	echo "Opcao invalida!"; Trata_TKT;;
esac
}

TICKETS=""

# Funcao para baixar as atualizacoes do repositorio (git pull)
PULL () {
echo "Baixando atualizacoes do repositorio remoto"
echo ""

git pull

if [ $? = 0 ]; then
        echo " "
        echo " "
        echo "Ambiente atualizado com sucesso PULL!"
        echo " "
        echo " "
else
        echo " "
        echo "Falha na atualizacao do ambiente \ err PULL"
        exit
fi

}


# Funcao para baixar as atualizacoes do repositorio (git pull)
PULLOURS () {
echo "Baixando atualizacoes do repositorio remoto - em caso de conflito, manter versao do DESENVOLVEDOR"
echo ""

git pull -s ours

if [ $? = 0 ]; then
	echo " "
	echo " "
	echo "Ambiente atualizado com sucesso OURS!"
	echo " "
	echo " "
else
	echo " "
	echo "Falha na atualizacao do ambiente \ err PULLOURS"
	exit
fi

}

# Funcao para baixar as atualizacoes, mantendo as atualizacoes do repositorio
PULLTHEIRS () {
echo "Baixando atualizacoes do repositorio remoto - em caso de conflito, manter versao do REPOSITORIO"
echo ""

git pull -s recursive -X theirs

if [ $? = 0 ]; then
        echo " "
        echo " "
        echo "Ambiente atualizado com sucesso THEIRS!"
        echo " "
        echo " "
else
        echo " "
        echo "Falha na atualizacao do ambiente \ err PULL"
        exit
fi

}

# Funcao para subir as atualizacoes para o repositorio (git push)
PUSH () {
echo "subindo atualizacoes para o repositorio remoto"
echo ""

git push origin HEAD

if [ $? = 0 ]; then
        echo " "
        echo " "
        echo "Repositorio remoto atualizado com sucesso!!"
	echo " "
        echo " "
	exit
else
	echo " "
	echo " "
	echo "###############################################################################################"
        echo "####### PUSH REJEITADO, VEJA AS ALTERACOES DO REPOSITORIO E DEPOIS CONTINUE COM O COMMIT ######"
	echo "###############################################################################################"
	echo " "
	echo " "
	git diff --color origin/${LOCAL}

	echo " "
	echo " "
	echo "######################################################################################################################################################"
	echo "#DESEJA CONTINUAR COM AS ALTERACOES, ELIMINAR AS ALTERACOES DO REPOSITORIO OU ELIMINAR AS SUAS ALTERACOES? [ [c]ontinuar / [m]inhas / [r]epositorio ]#"
	echo "######################################################################################################################################################"
	echo " "
	echo " "
	read CONTINUA
	case $CONTINUA in
		'c')
			echo "### CONTINUANDO COM AS SUAS ALTERACOES E COM AS ALTERACOES DO REPOSITORIO ####"
			echo " "
			PULL
			PUSHDENOVO=1
		;;
		'm') 
			echo "### TEM CERTEZA DE QUE VOCE DESEJA ELIMINAR AS ALTERACOES DO REPOSITORIO E MANTER AS SUAS ALTERACOES? [ s / n ] ###";read CONFIRMA
			case $CONFIRMA in
				's')
					echo " "
					echo " "
					echo "### COMMITANDO SUAS ALTERACOES E ELIMANDO AS ALTERACOES DO REPOSITORIO ###";
					echo " "
					echo " "
					PULLOURS
					PODEPUSH=1
					if [ $? = 0 ]; then
					        echo " "
						echo "### REPOSITORIO ATUALIZADO COM AS SUAS ALTERACOES, COM SUCESSO! ###"
					        echo " "
					else
					        echo " "
						echo "Falha na atualizacao do ambiente \ err PULLOURS"
						exit
					fi
				;;
				'n')
					echo "### COMMIT CANCELADO ###"
					exit
				;;
				'*')
					echo "### OPCAO ERRADA, COMMIT CANCELADO ###"
					exit
				;;
			esac
		;;
		'r')
			echo "### TEM CERTEZA DE QUE VOCE DESEJA ELIMINAR AS SUAS ALTERACOES E MANTER A DO REPOSITORIO? [ s / n ] ###";read CONFIRMAREPO
                        case $CONFIRMAREPO in
                                's')
					echo " "
					echo " "
                                        echo "### ELIMINANDO SUAS ALTERACOES E MANTENDO AS DO REPOSITORIO ###";
					echo " "
					echo " "
                                        PULLTHEIRS
					PODEPUSH=1
                                        if [ $? = 0 ]; then
                                                echo " "
                                                echo "### SUA VERSAO FOI ATUALIZADA COM AS ALTERACOES DO REPOSITORIO, COM SUCESSO! ###"
                                                echo " "
                                        else
                                                echo " "
                                                echo "Falha na atualizacao do ambiente \ err PULLTHEIRS"
                                                exit
                                        fi
				;;
                                'n')
                                        echo "### COMMIT CANCELADO ###"
                                        exit
                                ;;
                                '*')
                                        echo "### OPCAO ERRADA, COMMIT CANCELADO ###"
					exit
                                ;;
			esac
		;;
		'*')
			echo "### OPCAO ERRADA, COMMIT CANCELADO ###"
			exit
		;;
	esac

#exit
#	if [ $? = 0 ]; then
#		echo "Ambiente atualizado com sucesso, continuando com o push.."
#		PUSH
#	else
#		echo "Possivel conflito, por favor resolva o conflito para continuar.... Deseja ver o diff do conflito? [ s / n ]";read VERDIFF
#		case $VERDIFF in
#			's') git diff --color;;
#			'n') echo "ATENCAO! Nao sera possivel continuar com o commit, sem que o conflito seja resolvido MANUALMENTE, procure por >>>HEAD em seus arquivos!";;
#			*) echo "Opcao invalida!";;
#		esac
#		echo "Saindo do commit, por favor RESOLVA O CONFLITO e tente novamente!"
#		exit
#	fi
fi

sleep 3
}

# Funcao para chamar o script que atualiza os outros ambientes dos programadores que nao tem permissao de acesso.
PULLOUTROS () {
echo "Atualizando ambiente padrao e dos desenvolvedores que nao tem acesso"
echo ""

sudo /bin/pull-${FUNC}.sh

if [ $? = 0 ]; then
        echo " "
        echo " "
        echo "Outros ambientes atualizados com sucesso!"
else
	echo " "
        echo "Falha na atualizacao dos outros ambientes \ err PULLOUTROS"
        exit
fi

sleep 3
}

echo "--------------------------------------------------"
echo "	Script de commit do repositorio ${MODULOATIVO}	"
echo "--------------------------------------------------"


COLETASTATUS () {
# Coleta os arquivos alterados
GITSTATUS=`git status -s`

# Coleta se a branch esta a frente
ISAHEAD=`git status | grep "Your branch is ahead"`
# Mostra a quantidade de commits a frente
NAHEAD=`echo ${ISAHEAD} | awk -F'by' '{ print $2}' | awk -F'commit' '{ print $1}'`
# Coleta se a branch esta atras
ISBEHIND=`git status | grep "Your branch is behind"`
# Mostra a quantidade de commits atras
NABEHIND=`echo ${ISBEHIND} | awk -F'by' '{ print $2}' | awk -F'commit' '{ print $1}'`
# Coleta a branch atual
LOCAL=`git branch | awk -F "* " '{print $2}'`


if [[ -z $GITSTATUS ]];then
	STATUS=0
else
	STATUS=1
fi

}

# FUNCOES FIM

COLETASTATUS

# Libera passagem para o commit, quando a copia de trabalho esta a frente ou atras do repositorio
PODECOMMIT=0
if [[ -n $ISAHEAD || -n $ISBEHIND ]];then
PODECOMMIT=1
STATUS=1
fi

test "$STATUS" = 0 && echo "Nao existe nada para commitar, saindo" && exit


if [[ $LOCAL != "master" || $PODECOMMIT = 1 ]];then

	echo "Iniciando commit em: ${LOCAL}"
	echo "Tem certeza? [s/n]"; read COMMIT
	
	case $COMMIT in
	'n') 	echo "Commit abortado, saindo."; exit;;
	's') 	VAICOMMITAR=1;;
	*)	echo "Opcao invalida, saindo"; exit;;
	esac

	if [[ -n $ISAHEAD ]];then
		echo "Sua copia de trabalho esta a ${NAHEAD} commits a frente do repositorio"
		echo "Deseja subir suas atualizacoes? [s/n]"; read PUSHAHEAD
		case $PUSHAHEAD in
			'n')	echo "Commit cancelado, por favor, suba suas alteracoes para continuar commitando."; exit ;;
			's')	echo "Realizando o push"
				PUSH 
				COLETASTATUS
				test "$STATUS" = 0 && echo "Nao existe nada para commitar, saindo" && exit;;
			*) echo "Opcao invalida, saindo"; exit ;;
		esac
	elif [[ -n $ISBEHIND ]];then
        	echo "Sua copia de trabalho esta atras do repositorio em ${NBEHIND} commit"
        	echo "Deseja baixar suas atualizacoes? [s/n]"; read PULLBEHIND
                case $PULLBEHIND in
                      	'n')    echo "Atualizacao cancelada, por favor, atualize sua versao para continuar commitando."; exit ;;
                       	's')    echo "Atualizando sua copia"
                               	PULL
				COLETASTATUS
				test "$STATUS" = 0 && echo "Nao existe nada para commitar, saindo" && exit;;
                       	*) echo "Opcao invalida, saindo"; exit ;;
                esac
	elif [[ -n $GITSTATUS ]];then
		echo "Arquivos alterados:"
		echo ""
		echo "$GITSTATUS"
		echo ""
	fi

	if test "$VAICOMMITAR" = 1;then
		echo "Digite sua mensagem de commit:"; read MSG
	else
		echo "Erro no commit / VAICOMMITAR= ${VAICOMMITAR}"; exit;
	fi

	if [[ -n $MSG ]];then
		echo " "
		echo "Adicionando arquivos para commit"

		git add -A
		if [ $? == 0 ];then
			echo "Arquivos adicionados ao commit com sucesso!";
		else
			echo "Erro ao adicionar os arquivos, saindo"; exit
		fi

		echo " "
		# Chama funcao do ticket
	        Trata_TKT
		# Coleta a mensagem de commit e/ou mensagem de commit com o ticket
		if [[ -n $TICKETS ]];then
			git commit -m "$MSG $TICKETS" > /$HOME/.gitcommit.log
			if [ $? == 0 ];then
				echo "Commit com ticket realizado com sucesso!"
				PODEPUSH=1
			else
				echo "Falha no commit, verifique o log: `cat /$HOME/.gitcommit.log`"
				PODEPUSH=0
				exit
			fi
	        else
	        	git commit -m "$MSG" > /$HOME/.gitcommit.log
			if [ $? == 0 ];then
                                echo "Commit realizado com sucesso!"
				PODEPUSH=1
                        else
                                echo "Falha no commit, verifique o log: `cat /$HOME/.gitcommit.log`"
				PODEPUSH=0
                                exit
                        fi
	       	fi
		# Inicia o processo de push para o repositorio remoto e atualizacao dos outros ambientes
		if [ $PODEPUSH = 1 ]; then
			echo ""
			PUSH
	                echo ""
        	        #PULLOUTROS
		else
			echo "Erro no commit, impossivel fazer o push"
			exit
		fi
		if [ $PUSHDENOVO = 1 ]; then
                        echo ""
                        PUSH
                        echo ""
                        #PULLOUTROS
                else
                        echo "Erro no commit, impossivel fazer o push"
                        exit
                fi

	fi		
fi

if [ $LOCAL = "master" ];then

	echo "Voce esta na branch errada, voltando para branch develop"
	git checkout develop
	exit
fi

exit


