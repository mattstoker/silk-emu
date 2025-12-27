//
//  CPU6502+T.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

extension CPU6502 {
    
    // TAX
    // Transfer Accumulator to Index X
    //
    // A -> X
    // N    Z    C    I    D    V
    // +    +    -    -    -    -
    // addressing    assembler    opc    bytes    cycles
    // implied       TAX          AA     1        2
    mutating func executeTAX() {
        xr = ac
    }
    
    // TXA
    // Transfer Index X to Accumulator
    //
    // X -> A
    // N    Z    C    I    D    V
    // +    +    -    -    -    -
    // addressing    assembler    opc    bytes    cycles
    // implied       TXA          8A     1        2
    mutating func executeTXA() {
        ac = xr
    }
    
    // TAY
    // Transfer Accumulator to Index Y
    //
    // A -> Y
    // N    Z    C    I    D    V
    // +    +    -    -    -    -
    // addressing    assembler    opc    bytes    cycles
    // implied       TAY          A8     1        2
    mutating func executeTAY() {
        yr = ac
    }
    
    // TYA
    // Transfer Index Y to Accumulator
    //
    // Y -> A
    // N    Z    C    I    D    V
    // +    +    -    -    -    -
    // addressing    assembler    opc    bytes    cycles
    // implied       TYA          98     1        2
    mutating func executeTYA() {
        ac = yr
    }
    
    // TSX
    // Transfer Stack Pointer to Index X
    //
    // SP -> X
    // N    Z    C    I    D    V
    // +    +    -    -    -    -
    // addressing    assembler    opc    bytes    cycles
    // implied       TSX          BA     1        2
    mutating func executeTSX() {
        xr = sp
    }
    
    // TXS
    // Transfer Index X to Stack Register
    //
    // X -> SP
    // N    Z    C    I    D    V
    // -    -    -    -    -    -
    // addressing    assembler    opc    bytes    cycles
    // implied       TXS          9A     1        2
    mutating func executeTXS() {
        sp = xr
    }
}
