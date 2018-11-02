################################################################
#
# Section définie par l'utilsateur : nom du projet et composantes
#
#   contraintes  (amendables) d'implémentation choisies pour ce premier jet:
#
#       chaque composante est décrite par un mot composé d'une lettre 
#       définissant la fréquence, et d'un nombre définissant le
#       temps d'exposition en secondes. Les règles du Makefile utilise
#		ces contraintes donc si on les modifie (si on veut plus de caracteres
#		pour FREQ par exemple, il faudra modifier les recettes du Makefile
#		en conséquence. L = NOFILTER
#						R = RED
#						G = GREEN
#						B = BLUE
#						O = OIII
#						H = Halpha
#						A = Aucune idée
#						...
#
#
project=projectname
components=L300 L120 L30 R60 G60 B60 A60 H120 K60
#
# Fin de la section observateur 
###################################################################################################
# Section générique : elle traduit une 
# stratégie d'acquisition/traitement classique en tâches ACQ et PROCESS.
#
# On créée 3 fichiers séparés, pour la facilité de lecture :
#   le fichier .tasks contient toutes les tâches ACQ et PROCESS, dans l'ordre
#   où elles sont générées par le Makefile, donc c'est un ordre consistant :
#   les tâches PROCESS apparaissent apres que les acquisitions nécessaires
#   aient été programmées.
#
#   le fichier projectname.acq ne contient que les tâches d'acquisition
#
#   le fichier projectname.process ne contient que le tâches de traitement, 
#   c'est un squelette symbolique du script final de traitement.
#
.SILENT:project
SHELL := /bin/bash
explist := $(shell for i in $(components); do echo $${i:1}; done | sort | uniq)
freqlist := $(shell for i in $(components); do echo $${i:0:1}; done | sort | uniq)
darklist := $(shell for i in $(explist); do echo Master_Dark_$$i; done)
lightlist := $(shell for i in $(components); do echo Master_Light_$$i; done)
flatlist := $(shell for i in $(freqlist); do echo Master_Flat_$$i; done)
biaslist := Master_Bias
acq := $(project).acq
process := $(project).process
tasks := $(project).tasks
rm := $(shell rm $(acq) $(process) $(tasks) 2>/dev/null)

project: $(biaslist) $(darklist)  $(flatlist) $(lightlist)
	@echo NEWPROCESS makemaster ${lightlist} |tee -a $(process)|tee -a $(tasks)

Master_Bias: Seq_Bias
	@echo NEWPROCESS makemaster IMAGETYP="Bias" |tee -a $(process)|tee -a $(tasks)

Seq_Bias:
	@echo NEWACQ Seq IMAGETYP='Bias' |tee -a $(acq)|tee -a $(tasks)

Master_Dark_%: Seq_Dark_%
	@echo NEWPROCESS makemaster IMAGETYP="Dark" EXPTIME=$* |tee -a $(process)|tee -a $(tasks)

Seq_Dark_%:
	@echo NEWACQ Seq IMAGETYP='Dark' EXPTIME=$* |tee -a $(acq)|tee -a $(tasks)

Master_Flat_%: Seq_Flat_%
	@echo NEWPROCESS makemaster IMAGETYP="Flat"  FREQ=$*  |tee -a $(process)|tee -a $(tasks)

Seq_Flat_%:
	@echo NEWACQ Seq IMAGETYP='Flat' FREQ=$* |tee -a $(acq)|tee -a $(tasks)

Master_Light_%: freq = $(shell i=$(*); echo $${i:0:1})
Master_Light_%: exp =  $(shell i=$(*); echo $${i:1})
Master_Light_%: Seq_Light_%
	@echo NEWPROCESS makemaster IMAGETYP="Light" FREQ=$(freq) EXPTIME=$(exp) |tee -a $(process)|tee -a $(tasks)

Seq_Light_%: freq = $(shell i=$(*); echo $${i:0:1})
Seq_Light_%: exp =  $(shell i=$(*); echo $${i:1})
Seq_Light_%: 
	@echo NEWACQ Seq IMAGETYP='Light' EXPTIME=$(exp) FREQ=$(freq) |tee -a $(acq) |tee -a $(tasks)
