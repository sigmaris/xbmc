def main(ctx):
    suite = "bullseye"
    if ctx.build.event == "tag" and "-addons" in ctx.build.ref:
        return addons_pipelines(suite)
    elif ctx.build.event == "tag" and "-games" in ctx.build.ref:
        return games_pipelines(suite)
    else:
        return kodi_pipeline(suite)


def addons_pipelines(suite):
    return [
        single_addon_type_pipeline(suite, "audiodecoder"),
        single_addon_type_pipeline(suite, "audioencoder"),
        single_addon_type_pipeline(suite, "imagedecoder"),
        single_addon_type_pipeline(suite, "inputstream"),
        single_addon_type_pipeline(suite, "peripheral"),
        addon_type_pipeline(suite, "pvr", "pvr_a_to_m", "^pvr\\\\.[a-m].*"),
        addon_type_pipeline(suite, "pvr", "pvr_n_to_z", "^pvr\\\\.[n-z].*"),
        single_addon_type_pipeline(suite, "screensaver"),
        single_addon_type_pipeline(suite, "vfs"),
        single_addon_type_pipeline(suite, "visualization"),
    ]


def games_pipelines(suite):
    return [
        addon_type_pipeline(suite, "game", "game_libretro",        "^game\\\\.libretro$"),
        addon_type_pipeline(suite, "game", "game_libretro_number", "^game\\\\.libretro\\\\.[0-9].*"),
        addon_type_pipeline(suite, "game", "game_libretro_a_to_b", "^game\\\\.libretro\\\\.[a-b].*"),
        addon_type_pipeline(suite, "game", "game_libretro_c_to_e", "^game\\\\.libretro\\\\.[c-e].*"),
        addon_type_pipeline(suite, "game", "game_libretro_f_to_g", "^game\\\\.libretro\\\\.[f-g].*"),
        addon_type_pipeline(suite, "game", "game_libretro_j_to_l", "^game\\\\.libretro\\\\.[j-l].*"),
        addon_type_pipeline(suite, "game", "game_libretro_ma",     "^game\\\\.libretro\\\\.ma.*"),
        addon_type_pipeline(suite, "game", "game_libretro_mb_z",   "^game\\\\.libretro\\\\.m[b-z].*"),
        addon_type_pipeline(suite, "game", "game_libretro_n_to_p", "^game\\\\.libretro\\\\.[n-p].*"),
        addon_type_pipeline(suite, "game", "game_libretro_q_to_s", "^game\\\\.libretro\\\\.[q-s].*"),
        addon_type_pipeline(suite, "game", "game_libretro_t_to_v", "^game\\\\.libretro\\\\.[t-v].*"),
        addon_type_pipeline(suite, "game", "game_libretro_w_to_z", "^game\\\\.libretro\\\\.[w-z].*"),
    ]


def kodi_pipeline(suite):
    docker_img = "ghcr.io/sigmaris/kodibuilder:%s" % suite
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "build_kodi_%s" % suite,
        "platform": {
            "os": "linux",
            "arch": "arm64",
        },
        "workspace": {
            "base": "/drone",
            "path": "kodi-src",
        },
        "steps": [
            # Build Kodi alone
            {
                "name": "build_kodi",
                "image": docker_img,
                "environment": {
                    "KODI_DISTRO_CODENAME": suite,
                },
                "commands": [
                    "cd ..",
                    "mkdir kodi-build",
                    "cd kodi-build",
                    "../kodi-src/docker/configure_kodi.sh",
                    "../kodi-src/docker/build_kodi.sh",
                    "rm -f packages/kodi-*-aarch64-Unspecified.deb",
                    "tar cjvf addons-dev-%s.tar.bz2 packages/kodi-addon-dev_*.deb packages/libkodiplatform-dev_*.deb packages/libkodiplatform17_*.deb" % suite,
                ],
            },

            # Publish kodi build artifacts to bintray for non-tag builds
            {
                "name": "publish_kodi",
                "image": docker_img,
                "environment": {
                    "KODI_DISTRO_CODENAME": suite,
                    "BINTRAY_USER": "sigmaris",
                    "BINTRAY_API_KEY": {"from_secret": "bintray_api_key"},
                },
                "commands": [
                    "cd /drone/kodi-build/packages",
                    "/drone/kodi-src/docker/publish_bintray.sh",
                ],
                "depends_on": ["build_kodi"],
                "when": {
                    "event": {"exclude": "tag"},
                },
            },

            # Upload artifacts to Github release for tag builds
            {
                "name": "release_kodi",
                "image": "plugins/github-release",
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                        "/drone/kodi-build/addons-dev-%s.tar.bz2" % suite,
                        "/drone/kodi-build/packages/*.deb",
                    ],
                    "checksum": [
                        "md5",
                        "sha1",
                        "sha256",
                    ]
                },
                "depends_on": ["build_kodi"],
                "when": {
                    "event": "tag",
                },
            },
        ]
    }


def single_addon_type_pipeline(suite, addons_type):
    return addon_type_pipeline(suite, addons_type, addons_type, "%s.*" % addons_type)


def addon_type_pipeline(suite, addons_type, job_id, regex):
    docker_img = "ghcr.io/sigmaris/kodibuilder:%s" % suite
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "build_%s_addons_%s" % (job_id, suite),
        "platform": {
            "os": "linux",
            "arch": "arm64",
        },
        "workspace": {
            "base": "/drone",
            "path": "kodi-src",
        },
        "steps": [
            {
                "name": "build_%s_addons" % job_id,
                "image": docker_img,
                "environment": {
                    "KODI_DISTRO_CODENAME": suite,
                    "ADDONS_TO_BUILD": regex,
                },
                "commands": [
                    "cd ..",
                    "mkdir kodi-build",
                    "cd kodi-build",
                    "../kodi-src/docker/configure_kodi.sh",
                    "../kodi-src/docker/extract_build_tarball.sh",
                    "../kodi-src/docker/prepare_addons.sh",
                    "../kodi-src/docker/patch_addons.sh '%s'" % addons_type,
                    "../kodi-src/docker/build_addons.sh",
                ],
            },
            {
                "name": "publish_%s_addons" % job_id,
                "image": "plugins/github-release",
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                        "/drone/kodi-build/build/addons_build/*.deb",
                        "/drone/kodi-build/build/addons_build/*.buildinfo",
                        "/drone/kodi-build/build/addons_build/*.changes",
                    ],
                },
                "depends_on": [
                    "build_%s_addons" % job_id,
                ],
                "when": {
                    "event": "tag",
                },
            }
        ]
    }
