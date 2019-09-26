#
#  Copyright (c) 2019  European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# 
# Author  : Jeong Han Lee
# email   : jeonghan.lee@gmail.com
# Date    : Monday, September 23 12:57:04 CEST 2019
# version : 0.0.1
#
## The following lines are mandatory, please don't change them.
where_am_I := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(E3_REQUIRE_TOOLS)/driver.makefile
include $(E3_REQUIRE_CONFIG)/DECOUPLE_FLAGS



## We exclude this for the following arch,
## but we may need them later
##
EXCLUDE_ARCHS = linux-ppc64e6500
EXCLUDE_ARCHS += linux-corei7-poky

APP:=.
APPDB:=$(APP)/db

ECMC_SUBDIRS = scripts general hardware motion

SCRIPTS += $(APP)/startup.cmd
SCRIPTS += $(foreach path, $(ECMC_SUBDIRS), $(wildcard $(APP)/$(path)/*.cmd) $(wildcard $(APP)/$(path)/*/*.cmd))

#
# ESS will put *.proto files in $(ecmccfg_DB) path
#
TEMPLATES += $(wildcard $(APP)/protocol/*.proto)

SCRIPTS += $(wildcard ../iocsh/*.iocsh)


ECMC_HW_TYPES += Beckhoff_1XXX
ECMC_HW_TYPES += Beckhoff_2XXX
ECMC_HW_TYPES += Beckhoff_3XXX
ECMC_HW_TYPES += Beckhoff_4XXX
ECMC_HW_TYPES += Beckhoff_5XXX
ECMC_HW_TYPES += Beckhoff_6XXX
ECMC_HW_TYPES += Beckhoff_7XXX
ECMC_HW_TYPES += Beckhoff_9XXX
ECMC_HW_TYPES += Kuhnke
ECMC_HW_TYPES += MicroEpsilon
ECMC_HW_TYPES += Technosoft

# We copy all db, template, and substitutions files into the installation path
# After tune the startup scripts, can we remove substitutions files?
# Monday, September 23 12:56:36 CEST 2019
#
TEMPLATES += $(wildcard $(APPDB)/*.db)
TEMPLATES += $(wildcard $(APPDB)/*.template)
TEMPLATES += $(wildcard $(APPDB)/*.substitutions)
TEMPLATES += $(foreach path, $(ECMC_HW_TYPES), $(wildcard $(APPDB)/$(path)/*.db) $(wildcard $(APPDB)/$(path)/*.template) $(wildcard $(APPDB)/$(path)/*.substitutions))


# We inflat substitutions files to db files and put them into $(APPDB)
USR_DBFLAGS += -I . -I ..
USR_DBFLAGS += -I $(EPICS_BASE)/db
USR_DBFLAGS += -I $(APPDB)
USR_DBFLAGS += $(foreach path, $(ECMC_HW_TYPES), -I $(APPDB)/$(path))
USR_DBFLAGS += -I $(ecmccfg_PATH)/$(E3_MODULE_VERSION)/db


SUBS += $(wildcard $(APPDB)/*.substitutions)
SUBS += $(foreach path, $(ECMC_HW_TYPES), $(wildcard $(APPDB)/$(path)/*.substitutions))



# 
# include $(E3_REQUIRE_CONFIG)/RULES_INFLATING_DB

db: $(SUBS) 

$(SUBS):
       @printf "Inflating database ... %44s >>> %40s \n" "$@" "$(basename $(@)).db"
       @rm -f  $(basename $(@)).db.d  $(basename $(@)).db
       @$(MSI) -D $(USR_DBFLAGS) -o $(basename $(@)).db -S $@  > $(basename $(@)).db.d
       @$(MSI)    $(USR_DBFLAGS) -o $(basename $(@)).db -S $@


.PHONY: db $(SUBS)

#
# include $(E3_REQUIRE_CONFIG)/RULES_INFLATING_DB


vlibs:

.PHONY: vlibs

