#
# set up box environment for other makefiles
#
# -----------------------------------------------------------------------------

# - Coolstream ----------------------------------------------------------------

# BOXTYPE            coolstream
#                   /          \
# BOXSERIES       hd1          hd2
#                 /           /   \
# BOXFAMILY    nevis      apollo kronos
#               /        /     | |     \
# BOXMODEL   nevis apollo shiner kronos kronos_v2

# - Armbox --------------------------------------------------------------------

# BOXTYPE            armbox ------ + ----- + -------- + ------ + ----- +
#                   /      \        \       \          \        \       \
# BOXSERIES      hd51      vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse
#                  |          |        |        |         |          |   |
# BOXFAMILY    bcm7251s    bcm7376  bcm7278  bcm7444s  bcm72604     bcm7252s
#              |      |       |        |        |         |          |   |
# BOXMODEL   hd51 bre2ze4k vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse

# - Mipsbox --------------------------------------------------------------------

# BOXTYPE          mipsbox
#                 /
# BOXSERIES    vuduo
#                |
# BOXFAMILY   bcm7335
#                |
# BOXMODEL     vuduo

# -----------------------------------------------------------------------------

# assign by given BOXSERIES
ifneq ($(BOXSERIES),)
  ifeq ($(BOXSERIES), hd1)
    BOXTYPE = coolstream
    BOXFAMILY = nevis
    BOXMODEL = nevis
  else ifeq ($(BOXSERIES), hd2)
    BOXTYPE = coolstream
    BOXFAMILY = apollo
    BOXMODEL = apollo
  else ifeq ($(BOXSERIES), hd51)
    BOXTYPE = armbox
    BOXFAMILY = bcm7251s
    BOXMODEL = hd51
  else ifeq ($(BOXSERIES), vusolo4k)
    BOXTYPE = armbox
    BOXFAMILY = bcm7376
    BOXMODEL = vusolo4k
  else ifeq ($(BOXSERIES), vuduo4k)
    BOXTYPE = armbox
    BOXFAMILY = bcm7278
    BOXMODEL = vuduo4k
  else ifeq ($(BOXSERIES), vuultimo4k)
    BOXTYPE = armbox
    BOXFAMILY = bcm7444s
    BOXMODEL = vuultimo4k
  else ifeq ($(BOXSERIES), vuzero4k)
    BOXTYPE = armbox
    BOXFAMILY = bcm72604
    BOXMODEL = vuzero4k
  else ifeq ($(BOXSERIES), vuuno4k)
    BOXTYPE = armbox
    BOXFAMILY = bcm7252s
    BOXMODEL = vuuno4k
  else ifeq ($(BOXSERIES), vuuno4kse)
    BOXTYPE = armbox
    BOXFAMILY = bcm7252s
    BOXMODEL = vuuno4kse
  else ifeq ($(BOXSERIES), vuduo)
    BOXTYPE = mipsbox
    BOXFAMILY = bcm7335
    BOXMODEL = vuduo
  else
    $(error $(BOXTYPE) BOXSERIES $(BOXSERIES) not supported)
  endif

# assign by given BOXFAMILY
else ifneq ($(BOXFAMILY),)
  ifeq ($(BOXFAMILY), nevis)
    BOXTYPE = coolstream
    BOXSERIES = hd1
    BOXMODEL = nevis
  else ifeq ($(BOXFAMILY), apollo)
    BOXTYPE = coolstream
    BOXSERIES = hd2
    BOXMODEL = apollo
  else ifeq ($(BOXFAMILY), kronos)
    BOXTYPE = coolstream
    BOXSERIES = hd2
    BOXMODEL = kronos
  else ifeq ($(BOXFAMILY), bcm7251s)
    BOXTYPE = armbox
    BOXSERIES = hd51
    BOXMODEL = hd51
  else ifeq ($(BOXFAMILY), bcm7376)
    BOXTYPE = armbox
    BOXSERIES = vusolo4k
    BOXMODEL = vusolo4k
  else ifeq ($(BOXFAMILY), bcm7278)
    BOXTYPE = armbox
    BOXSERIES = vuduo4k
    BOXMODEL = vuduo4k
  else ifeq ($(BOXFAMILY), bcm7444s)
    BOXTYPE = armbox
    BOXSERIES = vuultimo4k
    BOXMODEL = vuultimo4k
  else ifeq ($(BOXFAMILY), bcm72604)
    BOXTYPE = armbox
    BOXSERIES = vuzero4k
    BOXMODEL = vuzero4k
  else ifeq ($(BOXFAMILY), bcm7252s)
    BOXTYPE = armbox
    BOXSERIES = vuuno4kse
    BOXMODEL = vuuno4kse
  else ifeq ($(BOXFAMILY), bcm7335)
    BOXTYPE = mipsbox
    BOXSERIES = vuduo
    BOXMODEL = vuduo
  else
    $(error $(BOXTYPE) BOXFAMILY $(BOXFAMILY) not supported)
  endif

# assign by given BOXMODEL
else ifneq ($(BOXMODEL),)
  ifeq ($(BOXMODEL), $(filter $(BOXMODEL), nevis))
    BOXTYPE = coolstream
    BOXSERIES = hd1
    BOXFAMILY = nevis
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), apollo shiner))
    BOXTYPE = coolstream
    BOXSERIES = hd2
    BOXFAMILY = apollo
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), kronos kronos_v2))
    BOXTYPE = coolstream
    BOXSERIES = hd2
    BOXFAMILY = kronos
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k))
    BOXTYPE = armbox
    BOXSERIES = hd51
    BOXFAMILY = bcm7251s
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vusolo4k))
    BOXTYPE = armbox
    BOXSERIES = vusolo4k
    BOXFAMILY = bcm7376
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuduo4k))
    BOXTYPE = armbox
    BOXSERIES = vuduo4k
    BOXFAMILY = bcm7278
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuultimo4k))
    BOXTYPE = armbox
    BOXSERIES = vuultimo4k
    BOXFAMILY = bcm7444s
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuzero4k))
    BOXTYPE = armbox
    BOXSERIES = vuzero4k
    BOXFAMILY = bcm72604
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuuno4k))
    BOXTYPE = armbox
    BOXSERIES = vuuno4k
    BOXFAMILY = bcm7252s
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuuno4kse))
    BOXTYPE = armbox
    BOXSERIES = vuuno4k
    BOXFAMILY = bcm7252s
  else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuduo))
    BOXTYPE = mipsbox
    BOXSERIES = vuduo
    BOXFAMILY = bcm7335
  else
    $(error $(BOXTYPE) BOXMODEL $(BOXMODEL) not supported)
  endif

endif

# -----------------------------------------------------------------------------

ifeq ($(BOXTYPE), coolstream)
  BOXTYPE_SC = cst
  BOXARCH = arm
else ifeq ($(BOXTYPE), armbox)
  BOXTYPE_SC = arm
  BOXARCH = arm
else ifeq ($(BOXTYPE), mipsbox)
  BOXTYPE_SC = mips
  BOXARCH = mips
endif

# -----------------------------------------------------------------------------

ifeq ($(BOXMODEL), nevis)
  BOXNAME="HD1, BSE, Neo, Neo², Zee"
else ifeq ($(BOXMODEL), apollo)
  BOXNAME="Tank"
else ifeq ($(BOXMODEL), shiner)
  BOXNAME="Trinity"
else ifeq ($(BOXMODEL), kronos)
  BOXNAME="Zee², Trinity V2"
else ifeq ($(BOXMODEL), kronos_v2)
  BOXNAME="Link, Trinity Duo"
else ifeq ($(BOXMODEL), hd51)
  BOXNAME="AX/Mut@nt HD51"
else ifeq ($(BOXMODEL), bre2ze4k)
  BOXNAME="WWIO BRE2ZE4K"
else ifeq ($(BOXMODEL), vusolo4k)
  BOXNAME="VU+ Solo 4K"
else ifeq ($(BOXMODEL), vuduo4k)
  BOXNAME="VU+ Duo 4K"
else ifeq ($(BOXMODEL), vuultimo4k)
  BOXNAME="VU+ Ultimo 4K"
else ifeq ($(BOXMODEL), vuzero4k)
  BOXNAME="VU+ Zero 4K"
else ifeq ($(BOXMODEL), vuuno4k)
  BOXNAME="VU+ Uno 4K"
else ifeq ($(BOXMODEL), vuuno4kse)
  BOXNAME="VU+ Uno 4K SE"
else ifeq ($(BOXMODEL), vuduo)
  BOXNAME="VU+ Duo"
endif

# -----------------------------------------------------------------------------

ifndef BOXTYPE
  $(error BOXTYPE not set)
endif
ifndef BOXTYPE_SC
  $(error BOXTYPE_SC not set)
endif
ifndef BOXARCH
  $(error BOXARCH not set)
endif
ifndef BOXSERIES
  $(error BOXSERIES not set)
endif
ifndef BOXFAMILY
  $(error BOXFAMILY not set)
endif
ifndef BOXMODEL
  $(error BOXMODEL not set)
endif
ifndef BOXNAME
  $(error BOXNAME not set)
endif
