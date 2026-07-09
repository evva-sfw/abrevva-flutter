module.exports = {
  git: {
    commitMessage: "chore: release ${version}",
    commit: false,
    tag: true,
    push: true,
    tagAnnotation: "Release ${version}",
    tagName: "${version}",
    commitArgs: "-S",
    tagArgs: "-s"
  },
  github: {
    release: true,
    releaseName: "Release ${version}",
    tokenRef: "BOT_GITHUB_TOKEN",
    releaseNotes(context) {
      return context.changelog;
    },
    assets: [
      "*.tgz"
    ]
  },
  npm: false,
  hooks: {
    "after:bump": [
      "echo ${version} > version",
      "rm -f *.tgz",
      "flutter pub get",
      "flutter pub publish --to-archive abrevva_${version}.tgz"
    ]
  },
  plugins: {
    "@release-it/conventional-changelog": {
      infile: "CHANGELOG.md",
      preset: {
        name: "conventionalcommits",
        types: [
          { type: "feat",     section: "🎉 Features"                },
          { type: "fix",      section: "🐛 Bug Fixes"               },
          { type: "perf",     section: "⚡️ Performance Improvements" },
          { type: "revert",   section: "⏪️ Reverts"                 },
          { type: "docs",     section: "📝 Documentation"           },
          { type: "style",    section: "🎨 Styles"                  },
          { type: "refactor", section: "🔀 Code Refactoring"        },
          { type: "test",     section: "🧪 Tests"                   },
          { type: "build",    section: "⚙️ Build System"            },
          { type: "ci",       section: "🚀 Continuous Integration"  },
          { type: "sec",      section: "🛡️ Security Fix"            },
          { type: "chore",    section: "🧹 Chore"                   }
        ]
      }
    }
  }
};