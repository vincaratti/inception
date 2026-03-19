COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/vcaratti/data

all: setup build up

setup:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

logs:
	$(COMPOSE) logs

clean: down
	$(COMPOSE) down -v --rmi all
	@sudo rm -rf $(DATA_DIR)/mariadb/*
	@sudo rm -rf $(DATA_DIR)/wordpress/*

re: clean all

.PHONY: all setup build up down start stop logs clean re
