PKG_NAME="libretro_cores"
PKG_LICENSE="GPL"
PKG_SITE="https://www.lakka.tv"
PKG_SECTION="virtual"
PKG_LONGDESC="Root package used to select libretro cores"

# List of libretro cores
LIBRETRO_CORES="\
                2048 \
                81 \
                a5200 \
                atari800 \
                beetle_bsnes \
                beetle_lynx \
                beetle_ngp \
                beetle_pce \
                beetle_pce_fast \
                beetle_pcfx \
                beetle_psx \
                beetle_saturn \
                beetle_supafaust \
                beetle_supergrafx \
                beetle_vb \
                beetle_wswan \
                blastem \
                bluemsx \
                bnes \
                boom3 \
                bsnes \
                bsnes2014 \
                bsnes_hd \
                bsnes_mercury \
                cannonball \
                cap32 \
                chailove \
                citra \
                craft \
                crocods \
                daphne \
                desmume \
                desmume_2015 \
                dinothawr \
                dirksimple \
                dolphin \
                dosbox \
                dosbox_core \
                dosbox_pure \
                dosbox_svn \
                easyrpg \
                emux_sms\
                ecwolf \
                ep128emu \
                fake_08 \
                fbalpha2012 \
                fbneo \
                fceumm \
                flycast \
                fmsx \
                freechaf \
                freeintv \
                fuse_libretro \
                gambatte \
                gearboy \
                gearsystem \
                genesis_plus_gx \
                genesis_plus_gx_wide \
                gme \
                gpsp \
                gw_libretro \
                handy \
                hatari \
                higan_sfc \
                higan_sfc_balanced \
                jaxe \
                jumpnbump \
                kronos \
                lowres_nx \
                lr_moonlight \
                lutro \
                mame \
                mame2000 \
                mame2003_plus \
                mame2010 \
                mame2015 \
                melonds \
                meowpc98 \
                mesen \
                mesen_s \
                mgba \
                mojozork \
                mrboom \
                mu \
                mupen64plus_next \
                neocd \
                nestopia \
                np2kai \
                numero \
                nxengine \
                o2em \
                openlara \
                opera \
                parallel_n64 \
                pcsx2 \
                pcsx_rearmed \
                picodrive \
                play \
                pocketcdg \
                pokemini \
                potator \
                ppsspp \
                prboom \
                prosystem \
                puae \
                puae2021 \
                px68k \
                quasi88 \
                quicknes \
                race \
                reminiscence \
                retro8 \
                same_cdi \
                sameboy \
                sameduck \
                scummvm \
                snes9x \
                snes9x2002 \
                snes9x2005 \
                snes9x2005_plus \
                snes9x2010 \
                stella \
                stella2014 \
                superbroswar \
                swanstation \
                tgbdual \
                theodore \
                thepowdertoy \
                tic80 \
                tyrquake \
                uae4arm \
                uzem \
                vbam \
                vecx \
                vice \
                virtualjaguar \
                vitaquake3 \
                wasm4 \
                xmil \
                xrick \
                yabasanshiro \
                yabause \
               "

# disable some cores
if [ "${PROJECT}" = "RPi" ]; then
  EXCLUDE_LIBRETRO_CORES+=" yabasanshiro"
  if [ "${DEVICE}" = "RPi" -o "${DEVICE}" = "GPICase" ]; then
    EXCLUDE_LIBRETRO_CORES+="\
                             beetle_bsnes \
                             beetle_psx \
                             beetle_saturn \
                             beetle_vb \
                             bk_emulator \
                             bsnes \
                             bsnes2014 \
                             bsnes_hd \
                             bsnes_mercury \
                             citra \
                             desmume \
                             desmume_2015 \
                             dolphin \
                             dosbox \
                             dosbox_core \
                             dosbox_pure \
                             dosbox_svn \
                             fbneo \
                             flycast \
                             genesis_plus_gx \
                             higan_sfc \
                             higan_sfc_balanced \
                             kronos \
                             lr_moonlight \
                             mame \
                             mame2003_plus \
                             mame2010 \
                             mame2015 \
                             melonds \
                             meowpc98 \
                             mesen \
                             mesen_s \
                             mupen64plus_next \
                             openlara \
                             opera \
                             parallel_n64 \
                             play \
                             ppsspp \
                             puae \
                             same_cdi \
                             snes9x \
                             snes9x2005_plus \
                             snes9x2010 \
                             swanstation \
                             uae4arm \
                             vbam \
                             virtualjaguar \
                             yabause \
                            "
  elif [ "${DEVICE}" = "RPi2" ]; then
    EXCLUDE_LIBRETRO_CORES+=" play"
  elif [ "${DEVICE}" = "Pi02GPi" ]; then
    EXCLUDE_LIBRETRO_CORES+=" kronos lr_moonlight melonds openlara play"
  fi
elif [ "${PROJECT}" = "Amlogic" -o "${PROJECT}" = "Rockchip" -o "${PROJECT}" = "Allwinner" ]; then
  EXCLUDE_LIBRETRO_CORES+=" yabasanshiro"
elif [ "${PROJECT}" = "Generic" -a "${ARCH}" = "i386" ]; then
  EXCLUDE_LIBRETRO_CORES+=" fake_08 lr_moonlight openlara"
elif [ "${PROJECT}" = "Ayn" -a "${DEVICE}" = "Odin" ]; then
  EXCLUDE_LIBRETRO_CORES+=" lr_moonlight"
elif [ "${PROJECT}" = "L4T" -a "${DEVICE}" = "Switch" ]; then
  EXCLUDE_LIBRETRO_CORES+=" kronos"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  #Core doesnt work with OPENGLES builds, as nanogui doesnt have support for that
  #Mental note fix OPENGLES in moonlight core gui/renderer.
  EXCLUDE_LIBRETRO_CORES+=" lr_moonlight"
fi

# disable cores that are only for specific targets
# fbalpha2012 and mame2000 only for RPi/GPICase
if [ "${PROJECT}" != "RPi" ]; then
  EXCLUDE_LIBRETRO_CORES+=" fbalpha2012 mame2000"
elif [ "${DEVICE}" != "RPi" -a "${DEVICE}" != "GPICase" ]; then
  EXCLUDE_LIBRETRO_CORES+=" fbalpha2012 mame2000"
fi
# boom3 and vitaquake for now only for Switch
if [ "${PROJECT}" != "L4T" -a "${DEVICE}" != "Switch" ]; then
  EXCLUDE_LIBRETRO_CORES+=" boom3 vitaquake3"
fi

# exclude some cores at build time
if [ -n "${EXCLUDE_LIBRETRO_CORES}" ]; then
  for core in ${EXCLUDE_LIBRETRO_CORES} ; do
    LIBRETRO_CORES="${LIBRETRO_CORES// ${core} /}"
  done
fi

# override above with custom list
if [ -n "${CUSTOM_LIBRETRO_CORES}" ]; then
  LIBRETRO_CORES="${CUSTOM_LIBRETRO_CORES}"
fi

# finally set package dependencies
PKG_DEPENDS_TARGET="${LIBRETRO_CORES}"
