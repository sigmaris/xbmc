def main(ctx):
    return pipeline("bullseye")


def pipeline(suite):
    addon_types = [
        "audiodecoder",
        "audioencoder",
        "game",
        "imagedecoder",
        "inputstream",
        "peripheral",
        "pvr",
        "screensaver",
        "vfs",
        "visualization",
    ]
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "build_%s" % suite,
        "platform": {
            "os": "linux",
            "arch": "arm64",
        },
        "workspace": {
            "base": "/drone",
            "path": "kodi-src",
        },
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/heads/rp64*",
                "refs/tags/*",
            ]
        },
        "steps": [
            # Stage 1: Build Kodi alone
            {
                "name": "build_kodi",
                "image": "sigmaris/kodibuilder:%s" % suite,
                "environment": {
                    "KODI_DISTRO_CODENAME": suite,
                },
                "commands": [
                    "cd ..",
                    "mkdir kodi-build-%s" % suite,
                    "cd kodi-build-%s" % suite,
                    "../kodi-src/docker/build_kodi.sh",
                    "rm -f packages/kodi-*-aarch64-Unspecified.deb",
                    "cd ..",
                    "tar cjvf kodi-build-%s.tar.bz2 kodi-build-%s" % (suite, suite),
                ],
                "when": {
                    "ref": {
                        "exclude": ["refs/tags/*-addons"]
                    }
                },
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
                        "/drone/kodi-build-%s.tar.bz2" % suite,
                        "/drone/kodi-build-%s/packages/*.deb" % suite,
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
                    "ref": {
                        "exclude": ["refs/tags/*-addons"]
                    }
                },
            },
        ] + [
            addons_build_step(suite, addon_type)
            for addon_type in addon_types
        ] + [
            addons_publish_step(suite, addon_type)
            for addon_type in addon_types
        ]
    }


def addons_build_step(suite, addons_type):
    return {
        "name": "build_%s_addons" % addons_type,
        "image": "sigmaris/kodibuilder:%s" % suite,
        "environment": {
            "KODI_DISTRO_CODENAME": suite,
            "ADDONS_TO_BUILD": "%s.*" % addons_type,
        },
        "commands": [
            "cd ..",
            "kodi-src/docker/extract_build_tarball.sh",
            "cd kodi-build-%s" % suite,
            "../kodi-src/docker/build_addons.sh",
        ],
        "when": {
            "ref": {
                "include": ["refs/tags/*-%s-addons" % addons_type]
            }
        },
    }


def addons_publish_step(suite, addons_type):
    return {
        "name": "publish_%s_addons" % addons_type,
        "image": "plugins/github-release",
        "settings": {
            "api_key": {
                "from_secret": "github_token",
            },
            "files": [
                "/drone/kodi-build-%s/build/addons_build/*.deb" % suite,
            ],
            "checksum": [
                "md5",
                "sha1",
                "sha256",
            ]
        },
        "depends_on": [
            "build_%s_addons" % addons_type,
        ],
        "when": {
            "event": "tag",
            "ref": {
                "include": ["refs/tags/*-%s-addons" % addons_type]
            }
        },
    }
