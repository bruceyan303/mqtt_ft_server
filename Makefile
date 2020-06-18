#*******************************************************************************
#  Copyright (c) 2009, 2020 IBM Corp.
#
#  All rights reserved. This program and the accompanying materials
#  are made available under the terms of the Eclipse Public License v2.0
#  and Eclipse Distribution License v1.0 which accompany this distribution.
#
#  The Eclipse Public License is available at
#     https://www.eclipse.org/legal/epl-2.0/
#  and the Eclipse Distribution License is available at
#    http://www.eclipse.org/org/documents/edl-v10.php.
#
#  Contributors:
#     Ian Craggs - initial API and implementation and/or initial documentation
#     Allan Stockdill-Mander - SSL updates
#     Andy Piper - various fixes
#     Ian Craggs - OSX build
#     Rainer Poisel - support for multi-core builds and cross-compilation
#*******************************************************************************/

# Note: on OS X you should install XCode and the associated command-line tools

SHELL = /bin/sh
#.PHONY: clean, mkdir, install, uninstall, html
.PHONY: clean, mkdir, 

MAJOR_VERSION := $(shell cat version.major)
MINOR_VERSION := $(shell cat version.minor)
PATCH_VERSION := $(shell cat version.patch)

TARGET = mqtt_ft_server

ifndef release.version
  release.version = $(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION)
endif

# determine current platform
BUILD_TYPE ?= debug
ifeq ($(OS),Windows_NT)
	OSTYPE ?= $(OS)
	MACHINETYPE ?= $(PROCESSOR_ARCHITECTURE)
else
	OSTYPE ?= $(shell uname -s)
	MACHINETYPE ?= $(shell uname -m)
	build.level = $(shell date)
endif # OS
ifeq ($(OSTYPE),linux)
	OSTYPE = Linux
endif

# assume this is normally run in the main Paho directory
ifndef srcdir
  srcdir = src
endif

ifndef blddir
  blddir = build/output
endif

ifndef blddir_work
  blddir_work = build
endif

ifndef docdir
  docdir = $(blddir)/doc
endif

ifndef docdir_work
  docdir_work = $(blddir)/../doc
endif

ifndef prefix
	prefix = /usr/local
endif

ifndef exec_prefix
	exec_prefix = ${prefix}
endif

bindir = $(exec_prefix)/bin
includedir = $(prefix)/include
libdir = $(exec_prefix)/lib
datarootdir = $(prefix)/share
mandir = $(datarootdir)/man
man1dir = $(mandir)/man1
man2dir = $(mandir)/man2
man3dir = $(mandir)/man3

SOURCE_FILES = $(wildcard $(srcdir)/*.c)
SOURCE_FILES_C = $(filter-out $(srcdir)/MQTTAsync.c $(srcdir)/MQTTVersion.c $(srcdir)/SSLSocket.c, $(SOURCE_FILES))
SOURCE_FILES_CS = $(filter-out $(srcdir)/MQTTAsync.c $(srcdir)/MQTTVersion.c, $(SOURCE_FILES))
SOURCE_FILES_A = $(filter-out $(srcdir)/MQTTClient.c $(srcdir)/MQTTVersion.c $(srcdir)/SSLSocket.c, $(SOURCE_FILES))
SOURCE_FILES_AS = $(filter-out $(srcdir)/MQTTClient.c $(srcdir)/MQTTVersion.c, $(SOURCE_FILES))

HEADERS = $(srcdir)/*.h
HEADERS_C = $(filter-out $(srcdir)/MQTTAsync.h, $(HEADERS))
HEADERS_A = $(HEADERS)

SAMPLE_FILES_C = MQTTClient_publish MQTTClient_publish_async MQTTClient_subscribe
SYNC_SAMPLES = ${addprefix ${blddir}/samples/,${SAMPLE_FILES_C}}

UTIL_FILES_CS = paho_cs_pub paho_cs_sub 
SYNC_UTILS = ${addprefix ${blddir}/samples/,${UTIL_FILES_CS}}

SAMPLE_FILES_A = MQTTAsync_subscribe MQTTAsync_publish
ASYNC_SAMPLES = ${addprefix ${blddir}/samples/,${SAMPLE_FILES_A}}

UTIL_FILES_AS = paho_c_pub paho_c_sub
ASYNC_UTILS = ${addprefix ${blddir}/samples/,${UTIL_FILES_AS}}

TEST_FILES_C = test1 test15 test2 sync_client_test test_mqtt4sync test10
SYNC_TESTS = ${addprefix ${blddir}/test/,${TEST_FILES_C}}

TEST_FILES_CS = test3
SYNC_SSL_TESTS = ${addprefix ${blddir}/test/,${TEST_FILES_CS}}

TEST_FILES_A = test4 test45 test6 test9 test95 test_mqtt4async test11
ASYNC_TESTS = ${addprefix ${blddir}/test/,${TEST_FILES_A}}

TEST_FILES_AS = test5
ASYNC_SSL_TESTS = ${addprefix ${blddir}/test/,${TEST_FILES_AS}}

# The names of the four different libraries to be built
MQTTLIB_C = paho-mqtt3c
MQTTLIB_CS = paho-mqtt3cs
MQTTLIB_A = paho-mqtt3a
MQTTLIB_AS = paho-mqtt3as

CC = gcc

ifndef INSTALL
INSTALL = install
endif
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA =  $(INSTALL) -m 644
DOXYGEN_COMMAND = doxygen

VERSION = ${MAJOR_VERSION}.${MINOR_VERSION}

MQTTLIB_C_NAME = lib${MQTTLIB_C}.so.${VERSION}
MQTTLIB_CS_NAME = lib${MQTTLIB_CS}.so.${VERSION}
MQTTLIB_A_NAME = lib${MQTTLIB_A}.so.${VERSION}
MQTTLIB_AS_NAME = lib${MQTTLIB_AS}.so.${VERSION}
MQTTVERSION_NAME = paho_c_version
PAHO_C_PUB_NAME = paho_c_pub
PAHO_C_SUB_NAME = paho_c_sub
PAHO_CS_PUB_NAME = paho_cs_pub
PAHO_CS_SUB_NAME = paho_cs_sub

MQTTLIB_C_TARGET = ${blddir}/${MQTTLIB_C_NAME}
MQTTLIB_CS_TARGET = ${blddir}/${MQTTLIB_CS_NAME}
MQTTLIB_A_TARGET = ${blddir}/${MQTTLIB_A_NAME}
MQTTLIB_AS_TARGET = ${blddir}/${MQTTLIB_AS_NAME}
MQTTVERSION_TARGET = ${blddir}/${MQTTVERSION_NAME}
PAHO_C_PUB_TARGET = ${blddir}/samples/${PAHO_C_PUB_NAME}
PAHO_C_SUB_TARGET = ${blddir}/samples/${PAHO_C_SUB_NAME}
PAHO_CS_PUB_TARGET = ${blddir}/samples/${PAHO_CS_PUB_NAME}
PAHO_CS_SUB_TARGET = ${blddir}/samples/${PAHO_CS_SUB_NAME}

#CCFLAGS_SO = -g -fPIC $(CFLAGS) -Os -Wall -fvisibility=hidden -I$(blddir_work) 
#FLAGS_EXE = $(LDFLAGS) -I ${srcdir} -lpthread -L ${blddir}
#FLAGS_EXES = $(LDFLAGS) -I ${srcdir} ${START_GROUP} -lpthread -lssl -lcrypto ${END_GROUP} -L ${blddir}

CCFLAGS_SO = -g -fPIC $(CFLAGS) -D_GNU_SOURCE -Os -Wall -fvisibility=hidden -I$(blddir_work) -DPAHO_MQTT_EXPORTS=1
FLAGS_EXE = $(LDFLAGS) -I ${srcdir} ${START_GROUP} -lpthread ${GAI_LIB} ${END_GROUP} -L ${blddir}
FLAGS_EXES = $(LDFLAGS) -I ${srcdir} ${START_GROUP} -lpthread ${GAI_LIB} -lssl -lcrypto -lpaho-mqtt3cs -lhiredis ${END_GROUP} -L ${blddir}

LDCONFIG ?= /sbin/ldconfig
LDFLAGS_C = $(LDFLAGS) -shared -Wl,-init,$(MQTTCLIENT_INIT) $(START_GROUP) -lpthread $(GAI_LIB) $(END_GROUP)
LDFLAGS_CS = $(LDFLAGS) -shared $(START_GROUP) -lpthread $(GAI_LIB) $(EXTRA_LIB) -lssl -lcrypto $(END_GROUP) -Wl,-init,$(MQTTCLIENT_INIT)
LDFLAGS_A = $(LDFLAGS) -shared -Wl,-init,$(MQTTASYNC_INIT) $(START_GROUP) -lpthread $(GAI_LIB) $(END_GROUP)
LDFLAGS_AS = $(LDFLAGS) -shared $(START_GROUP) -lpthread $(GAI_LIB) $(EXTRA_LIB) -lssl -lcrypto $(END_GROUP) -Wl,-init,$(MQTTASYNC_INIT)

SED_COMMAND = sed \
    -e "s/@CLIENT_VERSION@/${release.version}/g" \
    -e "s/@BUILD_TIMESTAMP@/${build.level}/g"

ifeq ($(OSTYPE),Linux)

MQTTCLIENT_INIT = MQTTClient_init
MQTTASYNC_INIT = MQTTAsync_init
START_GROUP = -Wl,--start-group
END_GROUP = -Wl,--end-group

GAI_LIB = -lanl
EXTRA_LIB = -ldl

LDFLAGS_C += -Wl,-soname,lib$(MQTTLIB_C).so.${MAJOR_VERSION}
LDFLAGS_CS += -Wl,-soname,lib$(MQTTLIB_CS).so.${MAJOR_VERSION} -Wl,-no-whole-archive
LDFLAGS_A += -Wl,-soname,lib${MQTTLIB_A}.so.${MAJOR_VERSION}
LDFLAGS_AS += -Wl,-soname,lib${MQTTLIB_AS}.so.${MAJOR_VERSION} -Wl,-no-whole-archive

else ifeq ($(OSTYPE),Darwin)

MQTTCLIENT_INIT = _MQTTClient_init
MQTTASYNC_INIT = _MQTTAsync_init
START_GROUP =
END_GROUP =

GAI_LIB = 
EXTRA_LIB = -ldl

CCFLAGS_SO += -Wno-deprecated-declarations -DOSX -I /usr/local/opt/openssl/include
LDFLAGS_C += -Wl,-install_name,lib$(MQTTLIB_C).so.${MAJOR_VERSION}
LDFLAGS_CS += -Wl,-install_name,lib$(MQTTLIB_CS).so.${MAJOR_VERSION} -L /usr/local/opt/openssl/lib
LDFLAGS_A += -Wl,-install_name,lib${MQTTLIB_A}.so.${MAJOR_VERSION}
LDFLAGS_AS += -Wl,-install_name,lib${MQTTLIB_AS}.so.${MAJOR_VERSION} -L /usr/local/opt/openssl/lib
FLAGS_EXE += -DOSX
FLAGS_EXES += -L /usr/local/opt/openssl/lib

LDCONFIG = echo

endif

SOURCE = $(wildcard $(srcdir)/samples/*.c)
OBJS = $(patsubst %.c,%.o,$(SOURCE))

all: build 


#build: | mkdir ${MQTTLIB_C_TARGET} ${MQTTLIB_CS_TARGET} ${MQTTLIB_A_TARGET} ${MQTTLIB_AS_TARGET} ${MQTTVERSION_TARGET} ${SYNC_SAMPLES} ${SYNC_UTILS} ${ASYNC_SAMPLES} ${ASYNC_UTILS} ${SYNC_TESTS} ${SYNC_SSL_TESTS} ${ASYNC_TESTS} ${ASYNC_SSL_TESTS}
build:mqtt

clean:
	rm -rf mqtt
	rm -rf ${blddir}/samples/*
	rm -rf ${blddir_work}/*

mkdir:
	-mkdir -p ${blddir}/samples
	echo OSTYPE is $(OSTYPE)
	echo ${SOURCE}

mqtt: $(OBJS)
	echo ${OBJS}
	$(CC) -o $@ $(OBJS) ${FLAGS_EXES}	

$(blddir_work)/VersionInfo.h: $(srcdir)/VersionInfo.h.in
	-mkdir -p $(blddir_work)
	$(SED_COMMAND) $< > $@
	
%.o:%.c
	$(CC) -o $@ -c $< ${FLAGS_EXES} 