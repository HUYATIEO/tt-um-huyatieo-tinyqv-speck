# x1 = 0x3b726574
ADDI x1, x0, 0x3b7      
SLLI x1, x1, 12
ADDI x1, x1, 0x265
SLLI x1, x1, 8
ADDI x1, x1, 0x74

# x2 = 0x7475432d
ADDI x2, x0, 0x747      
SLLI x2, x2, 12
ADDI x2, x2, 0x543      
SLLI x2, x2, 8
ADDI x2, x2, 0x2d

# x10 = 0x03020100
ADDI x10, x0, 0x030 
SLLI x10, x10, 12
ADDI x10, x10, 0x201
SLLI x10, x10, 8

# x11 = 0x0b0a0908
ADDI x11, x0, 0xb0       
SLLI x11, x11, 12
ADDI x11, x11, 0x500
ADDI x11, x11, 0x509      
SLLI x11, x11, 8
ADDI x11, x11, 0x08

# x5 = 0x13121110
ADDI x5, x0, 0x131 
SLLI x5, x5, 12
ADDI x5, x5, 0x211
SLLI x5, x5, 8
ADDI x5, x5, 0x10

#l2=0x1b1a1918
ADDI x6, x0, 0x1b1
SLLI x6, x6, 12
ADDI x6, x6, 0x500 
ADDI x6, x6, 0x519      
SLLI x6, x6, 8
ADDI x6, x6, 0x18

#x7,x8 = 0
ADDI x7,x0,0
ADDI x8,x0,0
ADDI x9,x0,27

speck:
SPECKSUM x1, x1, x2
XOR x1, x1, x10 #x1
SPECKXOR x2, x2, x1 #y1

SPECKSUM x11, x11, x10
XOR       x11, x11, x8 #l3
ADDI      x8, x8, 1 #i=+1
SPECKXOR x10, x10, x11 #k1

ADDI      x7, x11, 0    #l3->x7
ADDI      x11, x5, 0    #l1->x11
ADDI      x5, x6, 0    #l2->x5
ADDI      x6, x7, 0    #l3->x6
BLT       x8,x9,speck
done:    
         j done

