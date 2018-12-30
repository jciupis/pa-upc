/* Definitions and declaratioins of parameters (e.g. opcodes)
 * that will be used throughout the project
 */

/* OPCODE definitions */
`define OP_ADD	6'b00_0000	/* ADD	0x00 */
`define OP_SUB	6'b00_0001	/* SUB	0x01 */
`define OP_MUL	6'b00_0010	/* MUL	0x02 */
`define OP_LDB	6'b01_0000	/* LDB	0x10 */
`define OP_LDW	6'b01_0001	/* LDW	0x11 */
`define OP_STB	6'b01_0010	/* STB	0x12 */
`define OP_STW	6'b01_0011	/* STW	0x13 */
`define OP_BEQ	6'b11_0000	/* BEQ	0x30 */
`define OP_JMP	6'b11_0001	/* JMP	0x31 */

/* TODO */
