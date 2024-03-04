APPTAINER_CACHEDIR=/tmp
apptainer pull docker://ausar/controller_image
apptainer run controller_image_latest.sif
# apptainer run docker://ausar/controller_image