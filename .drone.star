def main(ctx):
    return [
        pipeline("buster"),
        pipeline("bullseye"),
    ]


def pipeline(suite):
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

            # Stage 2: build addons for tag with -addons
            {
                "name": "build_addons",
                "image": "sigmaris/kodibuilder:%s" % suite,
                "environment": {
                    "KODI_DISTRO_CODENAME": suite,
                },
                "commands": [
                    "cd ..",
                    "kodi-src/docker/extract_build_tarball.sh",
                    "cd kodi-build-%s" % suite,
                    "../kodi-src/docker/build_addons.sh",
                ],
                "when": {
                    "ref": {
                        "include": ["refs/tags/*-addons"]
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

            # Publish addons build artifacts
            {
                "name": "publish_addons",
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
                "depends_on": ["build_addons"],
                "when": {
                    "event": "tag",
                    "ref": {
                        "include": ["refs/tags/*-addons"]
                    }
                },
            },
        ]
    }
