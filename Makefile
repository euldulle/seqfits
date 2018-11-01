components=L300 L120 R60 G60 B60

.SILENT:project
SHELL := /bin/bash

explist := $(shell for i in $(components); do echo $${i:1}; done | sort | uniq)
freqlist := $(shell for i in $(components); do echo $${i:0:1}; done | sort | uniq)
darklist := $(shell for i in $(explist); do echo Master_Dark_$$i; done)
lightlist := $(shell for i in $(components); do echo Master_Light_$$i; done)
flatlist := $(shell for i in $(freqlist); do echo Master_Flat_$$i; done)
biaslist := Master_Bias

project: $(biaslist) $(darklist)  $(flatlist) $(lightlist)
#echo $(biaslist)
#echo $(darklist)
#echo $(lightlist)
#echo $(flatlist)
	@echo NEWPROCESS makemaster ${lightlist}

Master_Bias: Seq_Bias
	@echo NEWPROCESS makemaster IMAGETYP="Bias" SEQID="SeqBias"

Seq_Bias:
	@echo NEWACQ Seq IMAGETYP='Bias'

Master_Dark_%: Seq_Dark_%
	@echo NEWPROCESS makemaster IMAGETYP="Dark" SEQID=$< EXPTIME=$*

Seq_Dark_%:
	@echo NEWACQ Seq IMAGETYP='Dark' EXPTIME=$*

Master_Flat_%: Seq_Flat_%
	@echo NEWPROCESS makemaster IMAGETYP="Dark" SEQID=$< FREQ=$* 

Seq_Flat_%:
	@echo NEWACQ Seq IMAGETYP='Flat' FREQ=$*

Master_Light_%: freq = $(shell i=$(*); echo $${i:0:1})
Master_Light_%: exp =  $(shell i=$(*); echo $${i:1})
Master_Light_%: Seq_Light_%
	echo NEWPROCESS makemaster IMAGETYP="Light" SEQID=$< FREQ=$(freq) EXP=$(exp)

Seq_Light_%: freq = $(shell i=$(*); echo $${i:0:1})
Seq_Light_%: exp =  $(shell i=$(*); echo $${i:1})
Seq_Light_%: 
	@echo NEWACQ Seq IMAGETYP='Light' EXPTIME=$(exp) FREQ=$(freq)
