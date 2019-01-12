In order to generate instruction memory content from assembly code:
1. Create a assembly_instructions.txt file
2. Fill it with assembly lines you want to generate hex instructions from
3. Run assembly_encoder.py

Existing tests include:
1. assembly_instructions_all.txt - contains all supported types of instructions
2. assembly_instructions_icache.txt - contains only trivial adds and subs that are easy to track when debugging instruction memory
3. assembly_instructions_dcache.txt - contains loads and stores complemented with some dummy instructions to debug data memory
