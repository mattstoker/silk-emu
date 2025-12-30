//
//  CPU6502+ComparisonInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

// CMP
// Compare Memory with Accumulator
//
// A - M
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     CMP #oper    C9     2        2
// zeropage      CMP oper     C5     2        3
// zeropage,X    CMP oper,X   D5     2        4
// absolute      CMP oper     CD     3        4
// absolute,X    CMP oper,X   DD     3        4*
// absolute,Y    CMP oper,Y   D9     3        4*
// (indirect,X)  CMP (oper,X) C1     2        6
// (indirect),Y  CMP (oper),Y D1     2        5*

// CPX
// Compare Memory and Index X
//
// X - M
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     CPX #oper    E0     2        2
// zeropage      CPX oper     E4     2        3
// absolute      CPX oper     EC     3        4

// CPY
// Compare Memory and Index Y
//
// Y - M
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     CPY #oper    C0     2        2
// zeropage      CPY oper     C4     2        3
// absolute      CPY oper     CC     3        4
