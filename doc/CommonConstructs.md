# Common constructs

| Problem | Solution |
|---|---|
| Load 32-bit immediate | LDHI + OR |
| Move register | OR rd,ra,Z |
| Negate value | SUB rd,ra,Z |
| Subtract immediate from register | ADD rd,ra,-i14 |
| Invert all bits | NOR rd,ra,ra |
| Compare and branch | SUB + B[cc] |
| Unconditional branch | BEQ Z, offset |
| Unconditional subroutine branch | BLEQ Z, offset |
| Return from subroutine | J LR |
| Push to stack | ADD SP,SP,-N<br>STW ra,SP,0<br>... |
| Pop from stack | LDW rd,SP,0<br>...<br>ADD SP,SP,N |
| 64-bit integer addition: c2:c1 = a2:a1 + b2:b1 | ADD c1,a1,b1<br>ADD c2,a2,b2<br>SLTU carry,c1,a1<br>ADD c2,c2,carry|
| Floating point negation | LDHI + XOR |
| Floating point absolute value | LDHI + OR + AND |
| Floating point compare and branch | FSUB + B[cc] |
| Load simple floating point immediate (19 most significant bits) | LDHI |
