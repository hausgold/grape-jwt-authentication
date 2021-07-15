MAKEFLAGS += --warn-undefined-variables -j1
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.PHONY:

# Environment switches
MAKE_ENV ?= docker
COMPOSE_RUN_SHELL_FLAGS ?= --rm

# Directories
VENDOR_DIR ?= vendor/bundle

# Host binaries
AWK ?= awk
BASH ?= bash
COMPOSE ?= docker-compose
DOCKER ?= docker
GREP ?= grep
ID ?= id
MKDIR ?= mkdir
RM ?= rm
XARGS ?= xargs

# Container binaries
BUNDLE ?= bundle
GEM ?= gem
RAKE ?= rake
RUBOCOP ?= rubocop
YARD ?= yard

# Define a generic shell run wrapper
# $1 - The command to run
ifeq ($(MAKE_ENV),docker)
define run-shell
	$(COMPOSE) run $(COMPOSE_RUN_SHELL_FLAGS) \
		-e LANG=en_US.UTF-8 -e LANGUAGE=en_US.UTF-8 -e LC_ALL=en_US.UTF-8 \
		-e HOME=/home/web -e BUNDLE_APP_CONFIG=/app/.bundle \
		-u `$(ID) -u` test bash -c 'sleep 0.1; echo; $(1)'
endef
else ifeq ($(MAKE_ENV),baremetal)
define run-shell
	$(1)
endef
endif

all:
	# grape-jwt-authentication
	#
	# install            Install the dependencies
	# update             Update the local Gemset dependencies
	# clean              Clean the dependencies
	#
	# test               Run the whole test suite
	# test-style         Test the code styles
	#
	# docs               Generate the Ruby documentation of the library
	# stats              Print the code statistics (library and test suite)
	# notes              Print all the notes from the code
	# release            Release a new Gem version (maintainers only)
	#
	# shell              Run an interactive shell on the container
	# shell-irb          Run an interactive IRB shell on the container

install:
	# Install the dependencies
	@$(MKDIR) -p $(VENDOR_DIR)
	@$(call run-shell,$(BUNDLE) check || $(BUNDLE) install --path $(VENDOR_DIR))
	@$(call run-shell,GEM_HOME=vendor/bundle/ruby/$${RUBY_MAJOR}.0 \
		$(GEM) install bundler -v "~> 1.0")

test: \
	test-specs \
	test-style

test-specs:
	# Run the whole test suite
	@$(call run-shell,$(BUNDLE) exec $(RAKE) stats spec)

test-style: \
	test-style-ruby

test-style-ruby:
	# Run the static code analyzer (rubocop)
	@$(call run-shell,$(BUNDLE) exec $(RUBOCOP) -a)

clean:
	# Clean the dependencies
	@$(RM) -rf $(VENDOR_DIR)
	@$(RM) -rf $(VENDOR_DIR)/Gemfile.lock
	@$(RM) -rf pkg
	@$(RM) -rf coverage

clean-containers:
	# Clean running containers
ifeq ($(MAKE_ENV),docker)
	@$(COMPOSE) down
endif

clean-images:
	# Clean build images
ifeq ($(MAKE_ENV),docker)
	@-$(DOCKER) images | $(GREP) rimless \
		| $(AWK) '{ print $$3 }' \
		| $(XARGS) -rn1 $(DOCKER) rmi -f
endif

distclean: clean clean-containers clean-images

shell:
	# Run an interactive shell on the container
	@$(call run-shell,$(BASH) -i)

shell-irb:
	# Run an interactive IRB shell on the container
	@$(call run-shell,bin/console)

docs:
	# Build the API documentation
	@$(call run-shell,$(BUNDLE) exec $(YARD) -q && \
		$(BUNDLE) exec $(YARD) stats --list-undoc --compact)

notes:
	# Print the code statistics (library and test suite)
	@$(call run-shell,$(BUNDLE) exec $(RAKE) notes)

stats:
	# Print all the notes from the code
	@$(call run-shell,$(BUNDLE) exec $(RAKE) stats)

release:
	# Release a new gem version
	@$(BUNDLE) exec $(RAKE) release
