# Binaries will be generated with this name (.elf, .bin, .hex)
TARGET=template

ST_MCU_FAMILY=STM32F429_439xx
USE_STD_PERPH ?= 1

PROJ_APP_DIR=./srcs
STDLIB_DIRS=./std_lib
DEVICE_DIR=./device_specific
LINKER_DIR=$(DEVICE_DIR)/linker_script

OBJDIR=debug
# Compilers definition.
CROSS_COMPILE = arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJDUMP = $(CROSS_COMPILE)objdump
OBJCOPY = $(CROSS_COMPILE)objcopy
SIZE = $(CROSS_COMPILE)size
DBG = $(CROSS_COMPILE)gdb

# Compilers setting.
OPT_LEVEL=O0

#DEVICE SPECIFIC COMPILER SETTINGS
C_LIB=nosys.specs
DEVICE_ARCH=cortex-m4
ENDINAN_TYPE=mlittle-endian
FPU=fpv4-sp-d16
FPU_CALC=soft
ARM_INSTR=mthumb

#LINKER SCRIPT
LD_SCRIPT=$(LINKER_DIR)/stm32_flash.ld

# Path to stlink folder for uploading code to board
STLINK=~/Embedded/stlink-1.5.1





APP_SRC_DIRS := $(sort $(dir $(shell find "$(PROJ_APP_DIR)" -type f -name '*.c')))
UNIQUE_APP_SRC_DIRS := $(strip $(shell echo $(APP_SRC_DIRS) | tr ' ' '\n' | sort -u))

APP_INC_DIRS := $(sort $(dir $(shell find "$(PROJ_APP_DIR)" -type f -name '*.h')))
UNIQUE_APP_INC_DIRS := $(strip $(shell echo $(APP_INC_DIRS) | tr ' ' '\n' | sort -u))

STDLIB_SRC_DIRS := $(sort $(dir $(shell find "$(STDLIB_DIRS)" -type f -name '*.c')))
UNIQUE_STDLIB_SRC_DIRS := $(strip $(shell echo $(STDLIB_SRC_DIRS) | tr ' ' '\n' | sort -u))

STDLIB_INC_DIRS := $(sort $(dir $(shell find "$(STDLIB_DIRS)" -type f -name '*.h')))
UNIQUE_STDLIB_INC_DIRS := $(strip $(shell echo $(STDLIB_INC_DIRS) | tr ' ' '\n' | sort -u))


DEVICE_SRC_DIRS := $(sort $(dir $(shell find "$(DEVICE_DIR)" -type f -name '*.c')))
UNIQUE_DEVICE_SRC_DIRS := $(strip $(shell echo $(DEVICE_SRC_DIRS) | tr ' ' '\n' | sort -u))

DEVICE_ASSMB_DIRS := $(sort $(dir $(shell find "$(DEVICE_DIR)" -type f -name '*.s')))
UNIQUE_DEVICE_ASSMB_DIRS := $(strip $(shell echo $(DEVICE_ASSMB_DIRS) | tr ' ' '\n' | sort -u))

DEVICE_INC_DIRS := $(sort $(dir $(shell find "$(DEVICE_DIR)" -type f -name '*.h')))
UNIQUE_DEVICE_INC_DIRS := $(strip $(shell echo $(DEVICE_INC_DIRS) | tr ' ' '\n' | sort -u))



ALL_SRC_DIRS= $(UNIQUE_APP_SRC_DIRS) $(UNIQUE_STDLIB_SRC_DIRS) $(UNIQUE_DEVICE_SRC_DIRS) $(UNIQUE_DEVICE_ASSMB_DIRS)

ALL_INC_DIRS= $(UNIQUE_APP_INC_DIRS) $(UNIQUE_STDLIB_INC_DIRS) $(UNIQUE_DEVICE_INC_DIRS) $(UNIQUE_DEVICE_ASSMB_DIRS)


C_SRCS_FILES=$(notdir $(foreach dir, $(ALL_SRC_DIRS),  $(wildcard $(dir)/*.c)))
ASSEMBLY_FILES=$(notdir $(foreach dir, $(UNIQUE_DEVICE_ASSMB_DIRS),$(wildcard $(dir)/*.s)))

SRCS= $(C_SRCS_FILES) $(ASSEMBLY_FILES)

# Define objects for all sources

OBJS = $(addprefix $(OBJDIR)/,$(patsubst %.c,%.o,$(C_SRCS_FILES)))
OBJS+= $(addprefix $(OBJDIR)/,$(patsubst %.s,%.o, $(ASSEMBLY_FILES)))

# # Add this list to VPATH, the place make will look for the source files
VPATH = $(ALL_SRC_DIRS)



CFLAGS_INC=-I. $(foreach dir, $(ALL_INC_DIRS), $(addprefix -I, $(dir)))

#Compiler  Prepocessor Flas For defines
DEF_DEVICE=-D$(ST_MCU_FAMILY)
DEF_LIB := $(if $(filter 1,$(USE_STD_PERPH)),-DUSE_STDPERIPH_DRIVER)

CFLAGS_defines=$(DEF_DEVICE)
CFLAGS_defines+=$(DEF_LIB)


TARGET_FLAGS=\
	-mcpu=$(DEVICE_ARCH)\
	-$(ENDINAN_TYPE)\
	-mfpu=$(FPU)\
	-mfloat-abi=$(FPU_CALC)\
	-$(ARM_INSTR)
	
#  -Wall -Wextra -Werror  -Wmissing-include-dirs
#-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"
CFLAGS=\
	-c \
    -std=gnu11 -Wall\
	--specs=$(C_LIB)\
	-$(OPT_LEVEL)\
	$(TARGET_FLAGS)\
	$(CFLAGS_INC)\
	-T $(LD_SCRIPT)\
	$(CFLAGS_defines)

LDFLAGS=\
    -W\
	-T $(LD_SCRIPT)\
    $(TARGET_FLAGS)
	




all: clean $(SRCS) build size
	@echo "Successfully finished..."

build: $(TARGET).elf $(TARGET).bin $(TARGET).lst

$(TARGET).elf: $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $(OBJDIR)/$@

$(OBJDIR)/%.o: %.c
	@mkdir -p $(OBJDIR)
	@echo "Building" $<
	$(CC) $(CFLAGS) -MMD -MP -MF"$(@:%.o=%.d)"  -c $< -o $@

$(OBJDIR)/%.o: %.s
	@echo "Building" $<
	$(CC) $(CFLAGS) -c $< -o $@

%.hex: %.elf
	@$(OBJCOPY) -O ihex $(OBJDIR)/$< $(OBJDIR)/$@

%.bin: %.elf
	@$(OBJCOPY) -O binary $(OBJDIR)/$< $(OBJDIR)/$@

%.lst: %.elf
	@$(OBJDUMP) -x -S $(OBJDIR)/$(TARGET).elf > $(OBJDIR)/$@

size: $(TARGET).elf
	@$(SIZE) $(OBJDIR)/$(TARGET).elf

disass: $(TARGET).elf
	@$(OBJDUMP) -d $(OBJDIR)/$(TARGET).elf

disass-all: $(TARGET).elf
	@$(OBJDUMP) -D $(OBJDIR)/$(TARGET).elf

debug:
	@$(DBG) --eval-command="target extended-remote :4242" \
	 $(OBJDIR)/$(TARGET).elf

burn:
	@st-flash write $(OBJDIR)/$(TARGET).bin 0x8000000

clean:
	@echo "Cleaning..."
	@rm -rf $(OBJDIR)/ 


files:
	@echo "vpath : $(VPATH)"
	@echo "all srcs directory : $(ALL_SRC_DIRS)"
	@echo "Assembly directory : $(UNIQUE_DEVICE_ASSMB_DIRS)"



.PHONY: all build size clean burn debug disass disass-all files