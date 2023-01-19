8f41 a2 11     LDX #11
8f43 de ee 87  DEC 87ee,x
8f46 30 03     BMI 8f4b
8f48 4c e3 8f  JMP 8fe3
8f4b ee 3b 8f  INC 8f3b
8f4e ad 3b 8f  LDA 8f3b
8f51 c9 05     CMP #05
8f53 90 03     BCC 8f58
8f55 4c e3 8f  JMP 8fe3
8f58 bd 12 88  LDA 8812,x
8f5b 9d ee 87  STA 87ee,x
8f5e bc dc 87  LDY 87dc,x
8f61 8a        TXA 
8f62 48        PHA 
8f63 0a        ASL 
8f64 0a        ASL 
8f65 aa        TAX 
8f66 e8        INX 
8f67 e8        INX 
8f68 e8        INX 
8f69 e8        INX 
8f6a 8e 84 8f  STX 8f84
8f6d aa        TAX 
8f6e 8e b6 8f  STX 8fb6
8f71 bd 24 88  LDA 8824,x
8f74 49 ff     EOR #ff
8f76 8d 7c 8f  STA 8f7c
8f79 b1 8c     LDA (8c),y
8f7b 29 ff     AND #ff
8f7d 91 8c     STA (8c),y
8f7f 20 ea 8f  JSR 8fea
8f82 e8        INX 
8f83 e0 18     CPX #18
8f85 90 ea     BCC 8f71
8f87 68        PLA 
8f88 aa        TAX 
8f89 bc dc 87  LDY 87dc,x
8f8c 20 ea 8f  JSR 8fea
8f8f 98        TYA 
8f90 9d dc 87  STA 87dc,x
8f93 48        PHA 
8f94 86 39     STX 39
8f96 bc 6c 88  LDY 886c,x
8f99 88        DEY 
8f9a 10 03     BPL 8f9f
8f9c bc 7e 88  LDY 887e,x
8f9f 98        TYA 
8fa0 9d 6c 88  STA 886c,x
8fa3 bd 90 88  LDA 8890,x
8fa6 8d aa 8f  STA 8faa
8fa9 be ab 81  LDX 81ab,y
8fac 8a        TXA 
8fad e8        INX 
8fae e8        INX 
8faf e8        INX 
8fb0 e8        INX 
8fb1 8e c0 8f  STX 8fc0
8fb4 aa        TAX 
8fb5 a0 14     LDY #14
8fb7 bd f2 8f  LDA 8ff2,x
8fba 99 24 88  STA 8824,y
8fbd c8        INY 
8fbe e8        INX 
8fbf e0 50     CPX #50
8fc1 90 f4     BCC 8fb7
8fc3 68        PLA 
8fc4 a8        TAY 
8fc5 a5 39     LDA 39
8fc7 0a        ASL 
8fc8 0a        ASL 
8fc9 aa        TAX 
8fca e8        INX 
8fcb e8        INX 
8fcc e8        INX 
8fcd e8        INX 
8fce 8e de 8f  STX 8fde
8fd1 aa        TAX 
8fd2 b1 8c     LDA (8c),y
8fd4 1d 24 88  ORA 8824,x
8fd7 91 8c     STA (8c),y
8fd9 20 ea 8f  JSR 8fea
8fdc e8        INX 
8fdd e0 18     CPX #18
8fdf 90 f1     BCC 8fd2
8fe1 a6 39     LDX 39
8fe3 ca        DEX 
8fe4 30 03     BMI 8fe9
8fe6 4c 43 8f  JMP 8f43
8fe9 60        RTS 
8fea c8        INY 
8feb c0 b0     CPY #b0
8fed 90 02     BCC 8ff1
8fef a0 00     LDY #00
