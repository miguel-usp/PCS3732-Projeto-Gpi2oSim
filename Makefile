INC_DIR = inc
SRC_DIR = src
OUT_DIR = out

# Source files
FONTES = $(SRC_DIR)/boot.s $(SRC_DIR)/mm.s $(SRC_DIR)/utils.s $(SRC_DIR)/user.c $(SRC_DIR)/gpio.c ${SRC_DIR}/mini_uart.c ${SRC_DIR}/monitor.c
LDSCRIPT = linker.ld
PROJECT = teste

# Output files
EXEC = $(OUT_DIR)/${PROJECT}.elf
MAP = $(OUT_DIR)/${PROJECT}.map
IMAGE = $(OUT_DIR)/${PROJECT}.img
HEXFILE = $(OUT_DIR)/${PROJECT}.hex
LIST = $(OUT_DIR)/${PROJECT}.list

PREFIXO = arm-none-eabi-
AS = ${PREFIXO}as
LD = ${PREFIXO}ld
GCC = ${PREFIXO}gcc
OBJCPY = ${PREFIXO}objcopy
OBJDMP = ${PREFIXO}objdump

ASM_OPTIONS = -g -I ${INC_DIR}
C_OPTIONS = -march=armv7-a -mtune=cortex-a7 -g -I ${INC_DIR} -Wall -nostdlib -nostartfiles -ffreestanding -mgeneral-regs-only
LD_OPTIONS = -lgcc -L /opt/gcc-arm-none-eabi/lib/gcc/arm-none-eabi/13.2.1

# Generate object files list
OBJETOS = $(patsubst $(SRC_DIR)/%.s, $(OUT_DIR)/%.o, $(patsubst $(SRC_DIR)/%.c, $(OUT_DIR)/%.o, $(FONTES)))

all: ${OUT_DIR} ${EXEC} ${IMAGE} ${LIST} ${HEXFILE}

# Create output directory
${OUT_DIR}:
	mkdir -p ${OUT_DIR}

# Gerar executável
${EXEC}: ${OBJETOS}
	${LD} -T ${LDSCRIPT} -M=${MAP} -o $@ ${OBJETOS} ${LD_OPTIONS}


# Gerar imagem
${IMAGE}: ${EXEC}
	${OBJCPY} ${EXEC} -O binary ${IMAGE}

# Gerar intel Hex
${HEXFILE}: ${EXEC}
	${OBJCPY} ${EXEC} -O ihex ${HEXFILE}

# Gerar listagem
${LIST}: ${EXEC}
	${OBJDMP} -sdt ${EXEC} > ${LIST}

# Compilar arquivos em C
$(OUT_DIR)/%.o: $(SRC_DIR)/%.c
	${GCC} ${C_OPTIONS} -c -o $@ $<

# Montar arquivos em assembler
$(OUT_DIR)/%.o: $(SRC_DIR)/%.s
	${AS} ${ASM_OPTIONS} -o $@ $<

# Limpar tudo
clean:
	rm -f $(OUT_DIR)/*.o ${EXEC} ${MAP} ${LIST} ${IMAGE} ${HEXFILE}
	rm -rf ${OUT_DIR}
