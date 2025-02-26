SRC = src
INC = inc
TEST = test
TEST_INC = test/inc
OBJ = obj
EOBJ = eobj
ODIR = build

SRCS = $(wildcard $(SRC)/*.c) \
		$(wildcard $(SRC)/*/*.c)
TESTS = $(wildcard $(TEST)/*.c)
OBJS = $(addprefix $(OBJ)/, $(notdir $(SRCS:.c=.o)))
EOBJS = $(addprefix $(EOBJ)/, $(notdir $(SRCS:.c=.o)))
TEST_OBJS = $(addprefix $(OBJ)/, $(notdir $(TESTS:.c=.o)))

CC = gcc
DEBUGGER = gdb
RM      = rm -rf
MKDIR   = @mkdir -p $(@D)
CFLAGS = -I$(INC) -g3

OPT += -O3

XCFLAGS = -ggdb3 -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 
XCFLAGS += -mfloat-abi=softfp -MD -std=c99 -c -Wextra -Wall -Wno-missing-braces -Wno-builtin-declaration-mismatch
XCFLAGS += $(OPT)

XCC = arm-none-eabi-gcc

embedded: $(EOBJS)

test: $(ODIR)/$(TEST)/test_runner

$(EOBJ)/%.o: $(SRC)/%.c
	$(MKDIR)  
	$(XCC) -o $@ $^ -c $(XCFLAGS) -I$(INC)

$(EOBJ)/%.o: $(SRC)/*/%.c
	$(MKDIR)  
	$(XCC) -o $@ $^ -c $(XCFLAGS) -I$(INC)

$(OBJ)/%.o: $(SRC)/%.c
	$(MKDIR)   
	$(CC) -o $@ $^ -c $(CFLAGS)

$(OBJ)/%.o: $(SRC)/**/%.c
	$(MKDIR)   
	$(CC) -o $@ $^ -c $(CFLAGS)

$(OBJ)/%.o: $(TEST)/%.c
	$(MKDIR)
	$(CC) -o $@ $^ -c $(CFLAGS) -I$(TEST_INC) -I$(INC)

$(ODIR)/$(TEST)/test_runner: $(TEST_OBJS) $(filter-out $(OBJ)/main.o, $(OBJS))
	$(MKDIR)
	$(CC) -o $@ $^ $(CFLAGS)

debug:
	$(DEBUGGER) --tui $(ODIR)/$(TEST)/test_runner

clean:
	-$(RM) $(OBJ)
	-$(RM) $(ODIR)
	-$(RM) $(EOBJ)

.PHONY: clean
