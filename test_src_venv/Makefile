.DEFAULT: help
help:
	@echo "make prepare-env"
	@echo "			prepare venv environment, use only once"
	@echo "make lint"
	@echo "			run pylint and mypy"
	@echo "make run"
	@echo "			run project"
	@echo "make clean"
	@echo "			delete venv created before"

.PHONY: clean run prepare-env delete-env

VENV_NAME ?= datadog-py3.7-venv
PYTHON ?= $(VENV_NAME)/bin/python3

$(VENV_NAME)/bin/activate: requirements.txt
	test -d $(VENV_NAME) || python3 -m venv $(VENV_NAME)
	$(PYTHON) -m pip install -U pip
	$(PYTHON) -m pip install -r requirements.txt
	touch $(VENV_NAME)/bin/activate

$(VENV_NAME)/deactivate: requirements.txt
	@if [ -d $(VENV_NAME) ]; \
        then \
       	$(PYTHON) -m pip freeze > $(VENV_NAME)/requirements.txt;\
		$(PYTHON) -m pip uninstall -r $(VENV_NAME)/requirements.txt -y;\
		rm -rf $(VENV_NAME);\
    else \
        echo “Cant clean, $(VENV_NAME) does not exist”;\
    fi

prepare-env: $(VENV_NAME)/bin/activate

delete-env: $(VENV_NAME)/deactivate

run: prepare-env
	$(PYTHON) main.py

profile: #todo

clean: delete-env