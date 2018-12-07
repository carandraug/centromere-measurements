idx = \
  01 \
  02 \
  03

DV_FILES += \
  $(foreach name_path, $(idx), data/CENPC_$(name_path)_R3D.dv)
