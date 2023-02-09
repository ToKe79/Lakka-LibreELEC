#!/bin/bash

build_core() {
	[ ! ${#} -eq 3 ] && { echo "invalid number of arguments" ; return 1 ; }
	IFS='|' read -r -a build  <<< "${1}"
	project=${build[0]}
	device=${build[1]}
	arch=${build[2]}
	target_name=${device:-$project}.${arch}
	local core=${2}
	local job=${3}
	echo -n "[${job}/${total_jobs}] ${target_name}: ${core}..."
	DISTRO=${distro} PROJECT=${project} DEVICE=${device} ARCH=${arch} ./scripts/build ${core} >/dev/null 2>&1
	if [ ! ${?} -eq 0 ]
	then
		echo "fail"
		echo "${target_name}: ${core}" >> ${failed}
		return 1
	fi
	for f in build.${distro}-${target_name}-5.0-devel/install_pkg/${core}-*/usr/lib/libretro/*_libretro.so
	do
		[ ! -f ${f} ] && break
		local core_name=$(basename ${f})
		local zip_name=${core_name}.zip
		[ -d ${path}/${target_name}/latest ] || mkdir -p ${path}/${target_name}/latest
		[ -f ${path}/${target_name}/latest/${zip_name} ] && rm ${path}/${target_name}/latest/${zip_name}
		zip -j ${path}/${target_name}/latest/${zip_name} ${f} >/dev/null 2>&1
	done
	echo "done"
	return 0
}

get_package() {
	[ ! ${#} -eq 2 ] && { echo "invalid number of arguments" ; return 1 ; }
	local core=${1}
	local job=${2}
	echo -n "[${job}/${total_c}] Downloading: ${core}..."
	./scripts/get ${core} >/dev/null 2>&1
	echo "done"
	return 0
}

export -f build_core
export -f get_package

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

echo -n "Updating libretro cores packages..."

updated_cores=""

while read -r line
do
	if [ -z "${updated_cores}" ]
	then
		updated_cores+="${line%% *}"
	else
		updated_cores+=" ${line%% *}"
	fi
done < <(./libretro_update.sh -c | grep " updated from ")

echo "done!"

if [ -z "${updated_cores}" ]
then
	echo "No cores udpated"
	exit 0
fi

echo "Following libretro cores were update: ${updated_cores// /, }"

git commit -a -m "buildbot: update libretro cores"

total_t=$(echo ${targets} | wc -w)
total_c=$(echo ${updated_cores} | wc -w)
total_jobs=$(( total_t * total_c ))
failed=$(mktemp)

export distro path total_c total_jobs failed

if [ ! -z "$(which parallel)" ]
then
	echo "Downloading updated packages..."
	parallel get_package {1} {#} ::: ${updated_cores}
	echo "All packages downloaded..."
	sleep 5
	parallel build_core {1} {2} {#} ::: ${targets} ::: ${updated_cores}
else
	declare -i i=0
	for target in ${targets}
	do
		for core in ${updated_cores}
		do
			i+=1
			build_core ${target} ${core} ${i}
		done
	done
fi

echo "Failed:"
cat ${failed}
rm ${failed}
