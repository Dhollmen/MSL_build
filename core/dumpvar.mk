# ---------------------------------------------------------------
# the setpath shell function in envsetup.sh uses this to figure out
# what to add to the path given the config we have chosen.
ifeq ($(CALLED_FROM_SETUP),true)

ifneq ($(filter /%,$(HOST_OUT_EXECUTABLES)),)
ABP:=$(HOST_OUT_EXECUTABLES)
else
ABP:=$(PWD)/$(HOST_OUT_EXECUTABLES)
endif

ANDROID_BUILD_PATHS := $(ABP)
ANDROID_PREBUILTS := prebuilt/$(HOST_PREBUILT_TAG)
ANDROID_GCC_PREBUILTS := prebuilts/gcc/$(HOST_PREBUILT_TAG)

# The "dumpvar" stuff lets you say something like
#
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-TARGET_OUT
# or
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-abs-HOST_OUT_EXECUTABLES
#
# The plain (non-abs) version just dumps the value of the named variable.
# The "abs" version will treat the variable as a path, and dumps an
# absolute path to it.
#
dumpvar_goals := \
	$(strip $(patsubst dumpvar-%,%,$(filter dumpvar-%,$(MAKECMDGOALS))))
ifdef dumpvar_goals

  ifneq ($(words $(dumpvar_goals)),1)
    $(error Only one "dumpvar-" goal allowed. Saw "$(MAKECMDGOALS)")
  endif

  # If the goal is of the form "dumpvar-abs-VARNAME", then
  # treat VARNAME as a path and return the absolute path to it.
  absolute_dumpvar := $(strip $(filter abs-%,$(dumpvar_goals)))
  ifdef absolute_dumpvar
    dumpvar_goals := $(patsubst abs-%,%,$(dumpvar_goals))
    ifneq ($(filter /%,$($(dumpvar_goals))),)
      DUMPVAR_VALUE := $($(dumpvar_goals))
    else
      DUMPVAR_VALUE := $(PWD)/$($(dumpvar_goals))
    endif
    dumpvar_target := dumpvar-abs-$(dumpvar_goals)
  else
    DUMPVAR_VALUE := $($(dumpvar_goals))
    dumpvar_target := dumpvar-$(dumpvar_goals)
  endif

.PHONY: $(dumpvar_target)
$(dumpvar_target):
	@echo $(DUMPVAR_VALUE)

endif # dumpvar_goals

ifneq ($(dumpvar_goals),report_config)
PRINT_BUILD_CONFIG:=
endif

endif # CALLED_FROM_SETUP


ifneq ($(PRINT_BUILD_CONFIG),)
$(info ==========================================)
HOST_OS_EXTRA:=$(shell python -c "import platform; print(platform.platform())")
$(info   SLIM_VERSION=$(SLIM_VERSION))
$(info   BUILD_ID=$(BUILD_ID))
$(info   PLATFORM_VERSION=$(PLATFORM_VERSION))
$(info   PLATFORM_VERSION_CODENAME=$(PLATFORM_VERSION_CODENAME))
$(info   TARGET_PRODUCT=$(TARGET_PRODUCT))
$(info   TARGET_BUILD_VARIANT=$(TARGET_BUILD_VARIANT))
$(info   TARGET_BUILD_TYPE=$(TARGET_BUILD_TYPE))
ifneq ($(TARGET_BUILD_APPS),)
$(info   TARGET_BUILD_APPS=$(TARGET_BUILD_APPS))
endif
$(info   TARGET_ARCH=$(TARGET_ARCH))
$(info   TARGET_ARCH_VARIANT=$(TARGET_ARCH_VARIANT))
$(info   TARGET_CPU_VARIANT=$(TARGET_CPU_VARIANT))
ifneq ($(TARGET_2ND_ARCH),)
$(info   TARGET_2ND_ARCH=$(TARGET_2ND_ARCH))
endif
ifneq ($(TARGET_2ND_ARCH_VARIANT),)
$(info   TARGET_2ND_ARCH_VARIANT=$(TARGET_2ND_ARCH_VARIANT))
endif
ifneq ($(TARGET_2ND_CPU_VARIANT),)
$(info   TARGET_2ND_CPU_VARIANT=$(TARGET_2ND_CPU_VARIANT))
endif
$(info   HOST_ARCH=$(HOST_ARCH))
$(info   HOST_OS=$(HOST_OS))
$(info   HOST_OS_EXTRA=$(HOST_OS_EXTRA))
$(info   HOST_BUILD_TYPE=$(HOST_BUILD_TYPE))
$(info   OUT_DIR=$(OUT_DIR))
ifeq ($(BLOCK_BASED_OTA),false)
  $(info BLOCK_BASED_OTA=false)
else
  $(info BLOCK_BASED_OTA=true)
endif
ifeq ($(WITH_DEXPREOPT),true)
  $(info WITH_DEXPREOPT=true)
else
  $(info WITH_DEXPREOPT=false)
endif
ifeq ($(WITH_DEXPREOPT_PIC),true)
  $(info WITH_DEXPREOPT_PIC=true)
else
  $(info WITH_DEXPREOPT_PIC=false)
endif
ifeq ($(DONT_DEXPREOPT_PREBUILTS),true)
  $(info DONT_DEXPREOPT_PREBUILTS=true)
else
  $(info DONT_DEXPREOPT_PREBUILTS=false)
endif
ifeq ($(DELETE_RECOVERY),true)
  $(info DELETE_RECOVERY=true)
else
  ifeq ($(DELETE_RECOVERY),false)
    $(info DELETE_RECOVERY=false)
  else
    $(info DELETE_RECOVERY=)
  endif
endif
ifeq ($(CYNGN_TARGET),true)
  $(info   CYNGN_TARGET=$(CYNGN_TARGET))
  $(info   CYNGN_FEATURES=$(CYNGN_FEATURES))
endif
$(info ==========================================)
endif
