APPTAINER_CACHEDIR=/tmp
apptainer pull docker://ausar/controller_image
apptainer run ausar/controller_image.sif
# apptainer run docker://ausar/controller_image