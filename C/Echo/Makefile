
########
# VARS #
########

CC=cc

DIR_SRC=./src
DIR_DST=./build

APP_CLIENT_NAME=EchoClient
APP_SERVER_NAME=EchoServer

APP_CLIENT_SRC=$(DIR_SRC)/$(APP_CLIENT_NAME).c
APP_SERVER_SRC=$(DIR_SRC)/$(APP_SERVER_NAME).c

APP_CLIENT_DST=$(DIR_DST)/$(APP_CLIENT_NAME)
APP_SERVER_DST=$(DIR_DST)/$(APP_SERVER_NAME)

###########
# TARGETS #
###########

all: server client

server: $(APP_SERVER_DST)

client: $(APP_CLIENT_DST)

$(APP_SERVER_DST): $(DIR_DST) $(APP_SERVER_SRC)
	$(CC) -Wall -ansi -pedantic -o $(APP_SERVER_DST) $(APP_SERVER_SRC)

$(APP_CLIENT_DST): $(DIR_DST) $(APP_CLIENT_SRC)
	$(CC) -Wall -ansi -pedantic -o $(APP_CLIENT_DST) $(APP_CLIENT_SRC)

$(DIR_DST):
	mkdir $(DIR_DST)

clean:
	rm -Rf $(DIR_DST)

