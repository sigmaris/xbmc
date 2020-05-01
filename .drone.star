def main(ctx):
    suite = "bullseye"
    if ctx.build.event == "tag" and "-addons" in ctx.build.ref:
        return all_addons_pipelines(suite)
    else:
        return kodi_pipeline(suite)


def all_addons_pipelines(suite):
    return [
        single_addon_type_pipeline(suite, "audiodecoder"),
        single_addon_type_pipeline(suite, "audioencoder"),
        single_addon_type_pipeline(suite, "game"),
        single_addon_type_pipeline(suite, "imagedecoder"),
        single_addon_type_pipeline(suite, "inputstream"),
        single_addon_type_pipeline(suite, "peripheral"),
        single_addon_type_pipeline(suite, "pvr"),
        single_addon_type_pipeline(suite, "screensaver"),
        single_addon_type_pipeline(suite, "vfs"),
        single_addon_type_pipeline(suite, "visualization"),
    ]


def kodi_pipeline(suite):
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
                "image": "sigmaris/kodibuilder:%s" % suite,
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

            # Publish kodi build artifacts
            {
                "name": "publish_kodi",
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
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "build_%s_addons_%s" % (addons_type, suite),
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
                "name": "build_%s_addons" % addons_type,
                "image": "sigmaris/kodibuilder:%s" % suite,
                "environment": {
                    "KODI_DISTRO_CODENAME": suite,
                    "ADDONS_TO_BUILD": "%s.*" % addons_type,
                },
                "commands": [
                    "cd ..",
                    "mkdir kodi-build",
                    "cd kodi-build",
                    "../kodi-src/docker/configure_kodi.sh",
                    "../kodi-src/docker/extract_build_tarball.sh",
                    "../kodi-src/docker/build_addons.sh",
                ],
            },
            {
                "name": "publish_%s_addons" % addons_type,
                "image": "plugins/github-release",
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                        "/drone/kodi-build/build/addons_build/*.deb",
                    ],
                },
                "depends_on": [
                    "build_%s_addons" % addons_type,
                ],
                "when": {
                    "event": "tag",
                },
            }
        ]
    }
