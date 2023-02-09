#!/bin/bash

. distributions/Lakka/options

distro="Lakka"

path="/var/www/nightly.builds.lakka.tv/.buildbot"

targets="\
	Allwinner|A64|aarch64 \
	Allwinner|H2-plus|arm \
	Allwinner|H3|arm \
	Allwinner|H5|aarch64 \
	Allwinner|H6|aarch64 \
	Allwinner|R40|arm \
	Amlogic|AMLGX|aarch64 \
	Ayn|Odin|aarch64 \
	Generic|Generic|i386 \
	Generic|Generic|x86_64 \
	L4T|Switch|aarch64 \
	Generic|wayland|x86_64 \
	Generic|x11|x86_64 \
	NXP|iMX6|arm \
	NXP|iMX8|aarch64 \
	Rockchip|RK3288|arm \
	Rockchip|RK3328|aarch64 \
	Rockchip|RK3399|aarch64 \
	RPi|GPICase|arm \
	RPi|Pi02GPi|arm \
	RPi|RPi|arm \
	RPi|RPi2|arm \
	RPi|RPi3|aarch64 \
	RPi|RPi4|aarch64 \
	RPi|RPi4-PiBoyDmg|aarch64 \
	RPi|RPi4-RetroDreamer|aarch64 \
	Samsung|Exynos|arm \
	"

for target in ${targets}
do
	IFS='|' read -r -a build  <<< "${target}"
	project=${build[0]}
	device=${build[1]}
	arch=${build[2]}
	target_name=${device:-$project}.${arch}

	for core in ${LIBRETRO_CORES}
	do
		for f in build.${distro}-${target_name}-5.0-devel/install_pkg/${core}-*/usr/lib/libretro/*_libretro.so
		do
			[ ! -f ${f} ] && break
			core_name=$(basename ${f})
			zip_name=${core_name}.zip
			[ -f ${path}/${target_name}/latest/${zip_name} ] && break
			echo -n "${target_name} - adding ${core}..."
			[ -d ${path}/${target_name}/latest ] || mkdir -p ${path}/${target_name}/latest
			zip -j ${path}/${target_name}/latest/${zip_name} ${f} >/dev/null 2>&1
			echo "done!"
		done
	done
done
